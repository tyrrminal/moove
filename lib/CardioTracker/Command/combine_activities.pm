package CardioTracker::Command::combine_activities;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Util 'getopt';
use DateTime;
use DateTime::Format::MySQL;
use List::Util qw(reduce uniq sum);

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean :existence);

has 'description' => 'Combine two or more activities into a single activiity';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run($self, @args) {
  my ($user,$date,$type,@activity_ids);
  getopt(
    \@args,
    'user=s' => \$user,
    'date=s' => \$date,
    'type=s' => \$type,
    'id=i'   => \@activity_ids
  );

  my @activities;
  if($user && $date && $type) {
    @activities = $self->get_activity_ids($user,$date,$type);
  } else {
    @activities = $self->check_activity_ids(@activity_ids)
  }
  $self->combine_activities(@activities) if(@activities > 1);
}

sub get_activity_ids($self, $user,$date,$type) {
  return $self->app->model('Activity')->search({
    '-and' => [
      \['DATE(start_time) = ?'   => $date],
      'activity_type.description'   => $type,
      '-or' => {
        'user.id'       => $user,
        'user.username' => $user
      }
    ],
  },{
    join => [
      'activity_type',
      'user'
    ],
    order_by => 'start_time'
  })->all;
}

sub check_activity_ids($self, @ids) {
  my @a = $self->app->model('Activity')->search({
    id => {'IN' => [@ids]}
  },{
    order_by => 'start_time'
  });
  my @r = (shift(@a));
  foreach my $activity (@a) {
    push(@r, $activity) if($activity->activity_type->id == $r[0]->activity_type->id);
  }
  return @r;
}

sub combine_activities($self,@acts) {
  my $mysql_tformat = DateTime::Format::Duration->new(pattern => '%T', normalize => 1);
  my $in_seconds = DateTime::Format::Duration->new(pattern => '%s', normalize => 1);

  my $activity_type = $acts[0]->activity_type;
  my $note = join("\n\n", map { $_->note } @acts);

  my %times = (
    start_time => $acts[0]->start_time,
    gross_time => $acts[-1]->last_activity_point->timestamp->clone->subtract_datetime($acts[0]->first_activity_point->timestamp),
    net_time   => DateTime::Duration->new(hours => 0, minutes => 0, seconds => 0),
    temp_time  => DateTime::Duration->new(hours => 0, minutes => 0, seconds => 0),
    hr_time    => DateTime::Duration->new(hours => 0, minutes => 0, seconds => 0),
  );
  my ($temp_total, $hr_total) = (0,0);
  foreach my $a (@acts) {
    $times{net_time} = $times{net_time}->add($a->result->net_time);
    if(defined($a->temperature)) {
      $times{temp_time}->add($a->result->net_time);
      $temp_total += $a->temperature * $in_seconds->format_duration($a->result->net_time)/60;
    }
    if(defined($a->result->heart_rate)) {
      $times{hr_time}->add($a->result->net_time);
      $hr_total += $a->result->heart_rate * $in_seconds->format_duration($a->result->net_time)/60;
    }
  }
  my $temperature = $temp_total ? $temp_total/($in_seconds->format_duration($times{temp_time})/60) : undef;
  my $heart_rate  = $hr_total   ? $hr_total/($in_seconds->format_duration($times{hr_time})/60)     : undef;

  my ($total_distance,$uom);
  my @units = uniq(map { $_->distance->uom->id } @acts);
  if(@units > 1) {
    $uom = $acts[0]->distance->normalized_unit;
    $total_distance = sum(map { $_->distance->normalized_value } @acts);
  } else {
    $uom = $acts[0]->distance->uom;
    $total_distance = sum(map { $_->distance->value } @acts);
  }

  print "Creating Distance ($total_distance ".$uom->abbreviation.")\n";
  my $distance = $self->app->model('Distance')->find_or_create({value => $total_distance, uom => $uom->id});
  print "Creating Result\n";
  my $result = $self->app->model('Result')->create({
    gross_time => $mysql_tformat->format_duration($times{gross_time}),
    net_time   => $mysql_tformat->format_duration($times{net_time}),
    heart_rate => $heart_rate
  });
  print "Creating Activity\n";
  my $activity = $self->app->model('Activity')->create({
    activity_type_id => $activity_type->id,
    start_time       => DateTime::Format::MySQL->format_datetime($times{start_time}),
    distance_id      => $distance->id,
    result_id        => $result->id,
    temperature      => $temperature,
    note             => $note
  });
  print "Linking to user\n";
  my $ua = $self->app->model('UserActivity')->create({
    user_id => $acts[0]->user_id,
    activity_id => $activity->id
  });
  print "Linking partial activities\n";
  foreach (@acts) {
    $_->update({ whole_activity_id => $activity->id });
  }
  print "Updating Pace\n";
  $result->update_pace();
}

1;
