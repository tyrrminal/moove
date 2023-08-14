package Moove::Controller::Activity;
use v5.38;

use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with qw(
  DCS::Base::Role::Rest::Collection
  DCS::Base::Role::Rest::Entity

  Moove::Controller::Role::ModelEncoding::Activity 
  Moove::Controller::Role::ModelEncoding::Activity::UserEventActivity
  Moove::Controller::Role::ModelEncoding::Distance
);
with 'Moove::Role::Import::Activity';
with 'Moove::Role::Unit::Conversion';

use Data::UUID;
use Module::Util qw(module_path);
use List::Util   qw(first sum min max);
use DCS::DateTime::Extras;
use Syntax::Keyword::Try;
use Mojo::Exception qw(raise);
use Mojo::JSON qw(decode_json);
use JSON::Validator;
use DateTime::Format::Duration::ISO8601;
use Time::Seconds;

use syntax 'junction';

use Moove::Util::Extraction qw(selective_field_extract);
use DCS::Util::NameConversion qw(convert_hash_keys snake_to_camel camel_to_snake);

use HTTP::Status   qw(:constants);
use DCS::Constants qw(:symbols);

use builtin      qw(true false);
use experimental qw(builtin for_list);

sub decode_model ($self, $data) {
  my $d  = {convert_hash_keys($data->%*, \&camel_to_snake)};
  my $at = $self->model('ActivityType')->find($d->{activity_type_id});
  return undef unless ($at);

  if (exists($d->{distance})) {
    if (defined($d->{distance})) {
      my $distance = $self->model('Distance')->find_or_create_in_units($d->{distance}->{value},
        $self->model('UnitOfMeasure')->find($d->{distance}->{unit_of_measure_id}));
      $d->{distance_id} = $distance->id;
    } else {
      $d->{distance_id} = undef;
    }
  }
  $d->{pace}       = $self->normalized_pace($d->{pace})   if (defined($d->{pace}));
  $d->{speed}      = $self->normalized_speed($d->{speed}) if (defined($d->{speed}));
  $d->{start_time} = $self->parse_iso_datetime($d->{start_time})->strftime('%FT%T');

  #<<< no tidy because it can't handle for-list syntax properly yet
  foreach my ($field, $key) ((group => "group_num", set => "set_num")) {
    $d->{$key} = $d->{$field} if (exists($d->{$field}));
  }
  my $activity = selective_field_extract($d, [qw(id activity_type_id workout_id group_num set_num note visibility_type_id)]);
  $activity->{activity_result} = selective_field_extract($d, [$at->valid_fields]);
  #>>>

  return $activity;
}

sub effective_user ($self) {
  if (my $username = $self->validation->param('username')) {
    if (my $user = $self->model('User')->find({username => $username})) {return $user}
  }
  return $self->current_user;
}

sub resultset ($self, %args) {
  my $rs = $self->SUPER::resultset();  
  $rs = $rs->search(
    undef, {
      prefetch => [
        {activity_result => [{distance => 'unit_of_measure'}, 'normalized_distance']},
        'workout',
        {activity_type => ['base_activity_type', 'activity_context']}
      ]
    }
  )->grouped unless($args{noprefetch});

  if ($self->validation->param('combine') // $args{combine} // true) {
    $rs = $rs->whole;
  } else {
    $rs = $rs->uncombined;
  }

  $rs = $rs->for_user($self->effective_user)->visible_to($self->current_user);

  if (my $workout_id = $self->validation->param('workoutID')) {
    my $workout = $self->model_find(Workout => $workout_id) or return $self->render_not_found('Workout');
    $rs = $rs->in_workout($workout);
  }
  if (defined($self->validation->param('activityTypeID'))) {
    my $activity_type_ids = $self->validation->every_param('activityTypeID');
    foreach my $activity_type_id ($activity_type_ids->@*) {
      $self->model_find(ActivityType => $activity_type_id) or return $self->render_not_found('ActivityType');
    }
    $rs = $rs->search({'me.activity_type_id' => {-in => $activity_type_ids}});
  }
  if (my $start_date = $self->validation->param('start')) {
    $rs = $rs->after_date($start_date);
  }
  if (my $end_date = $self->validation->param('end')) {
    $rs = $end_date eq 'current' ? $rs->before_now : $rs->before_date($end_date, true);
  }
  if (my $date = $self->validation->param('on')) {
    $rs = $rs->after_date($date)->before_date($date, true)
  }
  my $event_filter = $self->validation->param('event');
  if(defined($event_filter) ) {
    $rs = $rs->has_event($event_filter);
  }

  foreach my $distance_filter (($self->validation->every_param('distance')//[])->@*) {
    my ($value, $op) = $self->decode_distance_param($distance_filter);
    $rs = $rs->search({
      'normalized_distance.value' => {$op => $value}
    })
  }

  foreach my $time_filter (($self->validation->every_param('net_time')//[])->@*) {
    my ($value, $op) = $self->decode_time_param($time_filter);
    $rs = $rs->search({
      "activity_result.net_time" => {$op => $value}
    })
  }

  foreach my $time_filter (($self->validation->every_param('duration')//[])->@*) {
    my ($value, $op) = $self->decode_time_param($time_filter);
    $rs = $rs->search({
      "activity_result.duration" => {$op => $value}
    })
  }

  foreach my $time_filter (($self->validation->every_param('pace')//[])->@*) {
    my ($value, $op) = $self->decode_time_param($time_filter);
    $rs = $rs->search({
      "activity_result.pace" => {$op => $value}
    })
  }

  foreach my $speed_filter (($self->validation->every_param('speed')//[])->@*) {
    my ($value, $op) = $self->decode_distance_param($speed_filter, 'Rate');
    $rs = $rs->search({
      'activity_result.speed' => {$op => $value}
    })
  }

  return $rs;
}

sub decode_distance_param($self, $txt, $uom_type = 'Distance') {
  my $jv = JSON::Validator->new();
  $jv->schema({
    type => 'object',
    required => [qw(value uom_abbr op)],
    properties => {
      value => {type => 'number', minimum => 0},
      uom_abbr => {type => 'string'},
      op => {type => 'string', enum => [qw(= > >= < <=)]},
    }
  });
  my $f = decode_json($txt);
  if(my @errors = $jv->validate($f)) {
    die(@errors)
  }
  my $v = $f->{value};
  my $dist_uom_type = $self->model('UnitOfMeasureType')->find({description => $uom_type});
  my $unit = $self->model('UnitOfMeasure')->search({abbreviation => $f->{uom_abbr}, unit_of_measure_type_id => $dist_uom_type->id})->first;
  die("Invalid unit: " . $f->{uom_abbr}) unless($unit);
  $v *= $unit->normalization_factor if(defined($unit->normal_unit));
  return ($v, $f->{op})
}

sub decode_time_param($self, $txt) {
  my $jv = JSON::Validator->new();
  $jv->schema({
    type => 'object',
    required => ['value','op'],
    properties => {
      value => {type => 'string'},
      op => {type => 'string', enum => [qw(= > >= < <=)]}
    }
  });
  my $f = decode_json($txt);
  if(my @errors = $jv->validate($f)) {
    die(@errors);
  }
  die('/value: Does not match time format') unless($f->{value} =~ /^\d{1,}:\d{2}:\d{2}$/);
  return ($f->{value}, $f->{op});
}

sub custom_sort_for_column ($self, $col_name) {
  return 'normalized_distance.value'  if ($col_name eq 'distance');
  return 'activity_result.net_time'   if ($col_name eq 'time');
  return 'activity_result.pace'       if ($col_name eq 'pace');
  return 'activity_result.speed'      if ($col_name eq 'speed');
  return 'activity_result.start_time' if ($col_name eq 'startTime');
  return undef;
}

sub insert_record ($self, $data) {
  my $workout = $self->model('Workout')->find($data->{workout_id});
  $data->{group_num} = $workout->next_group_num                   if (!defined($data->{group_num}));
  $data->{set_num}   = $workout->next_set_num($data->{group_num}) if (!defined($data->{set_num}));
  return $self->SUPER::insert_record($data);
}

sub update_record ($self, $entity, $data) {
  foreach (qw(group_num set_num id workout_id)) {
    delete($data->{$_});
  }
  delete($data->{activity_result}->{id});
  $entity->activity_result->update(delete($data->{activity_result}));
  return $self->SUPER::update_record($entity, $data);
}

sub delete_record ($self, $entity) {
  $entity->activities->update({whole_activity_id => undef});
  $entity->user_event_activities->update({activity_id => undef});
  return $self->SUPER::delete_record($entity);
}

sub param_start($self) {
  if(my $v = $self->validation->param('start')) {
    return $self->parse_api_date($v);
  }
  return undef;
}

sub param_end($self, $check = false) {
  if(my $v = $self->validation->param('end')) {
    if($v eq 'current') {
      my $d = DateTime->now(time_zone => 'local')->truncate(to => 'day');
      $d->subtract(days => 1) if($check && $self->resultset->on_date($d)->count < 1);
      return $d;
    }
    return $self->parse_api_date($v);
  }
  return undef;
}

sub summary($self) {
  return unless ($self->openapi->valid_input);
  my $time_formatter = DateTime::Format::Duration::ISO8601->new();
  my $d_unit = $self->model('UnitOfMeasure')->search({ normal_unit_id => undef, 'unit_of_measure_type.description' => 'Distance' }, {join => 'unit_of_measure_type'})->first;
  my $s_unit = $self->model('UnitOfMeasure')->find({ abbreviation => 'mph' });
  my $p_unit = $self->model('UnitOfMeasure')->find({ abbreviation => '/mi' });
  my $una = $self->effective_user->user_nominal_activities;
  my $activities = $self->resultset(noprefetch => true)->completed;

  my $partition_type = $self->validation->param('partition');
  my $rev = ($partition_type//'') =~ /^time[.]/ ? sub {@_} : sub{reverse(@_)};

  my $ps = $self->param_start;
  my $pe = $self->param_end(true);

  my @summaries = $activities->summary($partition_type);
  unshift(@summaries, $activities->summary) if($partition_type && $self->validation->param('withRollup') && @summaries);
  my @r;
  foreach my $s (@summaries) {
    my $ctx = delete($s->{ctx});
    my $sd = $self->encode_date(first { defined } $rev->($ctx->{min_date}, $ps));
    my $ed = $self->encode_date(first { defined } $rev->($ctx->{max_date}, $pe));

    $s->{label} = $ctx->{label} if(defined($ctx->{label}));
    $s->{activityTypes} = $ctx->{activityTypes} if(defined($ctx->{activityTypes}));
    $s->{startDate} = $sd if($sd);
    $s->{endDate}   = $ed if($ed);
    if($s->{distance}) {
      foreach my $k (keys($s->{distance}->%*)) {
        $s->{distance}->{$k} = { value => $s->{distance}->{$k}//0, unitOfMeasureID => $d_unit->id };
      }
    }
    if($s->{speed}) {
      foreach my $k (keys($s->{speed}->%*)) {
        $s->{speed}->{$k} = { value => sprintf('%.03f', $s->{speed}->{$k}//0), unitOfMeasureID => $s_unit->id };
      }
    }
    if($s->{pace}) {
      foreach my $k (keys($s->{pace}->%*)) {
        $s->{pace}->{$k} = {value => $self->encode_time(DateTime::Duration->new(minutes => $s->{pace}->{$k}//0)), unitOfMeasureID => $p_unit->id };
      }
    }
    if($s->{time}) {
      foreach my $type (keys($s->{time}->%*)) {
        foreach my $k (keys($s->{time}->{$type}->%*)) {
          if(defined($s->{time}->{$type}->{$k})) {
            $s->{time}->{$type}->{$k} = $time_formatter->format_duration(sec_to_duration($s->{time}->{$type}->{$k}));
          }
        }
      }
    }

    if(!defined($partition_type) || $partition_type =~ /^activityType[.]/) {
      my $nom_rs = $una->for_type(map { $_->{id} } $ctx->{activityTypes}->@*);
      $nom_rs = $nom_rs->in_range($self->param_start,$self->param_end) if(defined($self->param_start) && defined($self->param_end));
      if($nom_rs->count) {
        my $nom_d = $nom_rs->nominal_distance_in_range($self->param_start, $self->param_end(true));
        $s->{distance}->{nominal} = $self->encode_model($nom_d);
      }
    }

    push(@r, {convert_hash_keys($s->%*, \&snake_to_camel)});
  }

  return $self->render(openapi => [@r]);
}

sub import ($self) {
  return unless ($self->openapi->valid_input);
  my $activities = [];

  try {
    my $asset = $self->param('file')->asset->to_file;
    my $ug    = Data::UUID->new;
    $asset->move_to(File::Spec->join($self->app->conf->paths->tmp, $ug->to_string($ug->create)));

    my $ds = $self->model_find(ExternalDataSource => $self->param('externalDataSourceID'))
      or $self->render_not_found('ExternalDataSource');

    my $import_class = $ds->import_class;
    require(module_path($import_class));
    my $importer = $import_class->new(file => $asset->path);

    foreach my $id ($importer->get_activities()) {
      my $data = $importer->get_activity_data($id);
      my ($activity, $is_existing) = $self->import_activity($data, $self->current_user);
      push($activities->@*, {$self->encode_model($activity)->%*, isNew => !$is_existing});

      if (!$is_existing && $activity->activity_type->activity_context->has_map) {
        my $job_id = $self->app->minion->enqueue(
          import_activity_points => [$import_class, $asset->path, $data->{activity_id}, $activity->activity_result_id]);
        $self->app->minion->result_p($job_id)->then(sub ($info) {$self->_cleanup_files($asset->path)});
      }
    }

    $self->_cleanup_files($asset->path);

    return $self->render(openapi => $activities);
  } catch ($e) {
    return $self->render_error(HTTP_BAD_REQUEST, $e)
  }
}

sub merge ($self) {
  return unless ($self->openapi->valid_input);

  try {
    my @to_merge;
    foreach ($self->req->json->@*) {
      my $activity = $self->model('Activity')->search({'me.id' => $_->{id}})->writable_by($self->current_user)->first
        or return $self->render_not_found('Activity');
      push(@to_merge, $activity);
    }

    my $activity = $self->model('Activity')->merge(@to_merge);
    $self->app->minion->enqueue(copy_activity_points => [$activity->id, join($COMMA, map {$_->id} @to_merge)]);
    return $self->render(openapi => $self->encode_model($activity));
  } catch ($e) {
    return $self->render_error(HTTP_BAD_REQUEST, $e)
  }
}

sub _cleanup_files ($self, $path) {
  return unless (-e $path);
  my $jobs = $self->app->minion->jobs({tasks => ['import_activity_points'], states => [qw(active inactive)]});
  while (my $info = $jobs->next) {
    return if ($info->{args}->[1] eq $path);
  }
  unlink($path);
}

sub quotient_remainder($dividend, $divisor) {
  use integer;
  my $quotient = $dividend / $divisor;
  my $remainder = $dividend % $divisor;
  return ( $quotient, $remainder );
}

sub sec_to_duration($t) {
  $t //= 0;
  my ($s,$m,$h,$d);
  ($m, $s) = quotient_remainder($t, ONE_MINUTE);
  ($h, $m) = quotient_remainder($m, ONE_HOUR/ONE_MINUTE);
  ($d, $h) = quotient_remainder($h, ONE_DAY/ONE_HOUR);
  return DateTime::Duration->new(seconds => $s, minutes => $m, hours => $h, days => $d)
}

1;
