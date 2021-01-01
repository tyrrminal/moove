package CardioTracker::Command::import_results;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Util 'getopt';

use Scalar::Util qw(looks_like_number);
use DateTime;

use CardioTracker::Import::Event::RaceWire;
use CardioTracker::Import::Event::IResultsLive;
use CardioTracker::Import::Event::MillenniumRunning;
use CardioTracker::Import::Event::MTEC;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:existence);
use Data::Dumper;

has 'description' => 'Import the results from a race or ride';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  my $import_class = 'CardioTracker::Import::Event::';

  getopt(
    \@args,
    'iresultslive' => sub {$import_class .= 'IResultsLive'},
    'racewire'     => sub {$import_class .= 'RaceWire'},
    'millennium'   => sub {$import_class .= 'MillenniumRunning'},
    'mtec'         => sub {$import_class .= 'MTEC'},
    'id=s'         => \my $id,
    'race=s'       => \my $race,
    'all'          => \my $import_all
  );

  if ($import_all) {
    foreach (
      $self->app->model('EventReference')->search({imported => 'N'}, {'join' => 'event', 'order_by' => 'event.scheduled_start'}))
    {
      next if ($_->event->scheduled_start > DateTime->now);
      $self->import_event($import_class . $_->event_reference_type->description, $_->ref_num, $_->sub_ref_num);
    }
  } else {
    $self->import_event($import_class, $id, $race);
  }
}

sub import_event ($self, $import_class, $id, $race) {
  say "id is required" and exit 1 unless (defined($id));
  say "results site is required" and exit 1 unless ($import_class->can('new'));

  my $importer = $import_class->new(event_id => $id, race_id => $race);

  my $event = $importer->find_and_update_event($self->app->model('Event'));
  say DateTime->now()->strftime('%F %T') . " Importing " . $event->description;

  foreach my $p ($importer->fetch_results()) {
    #lookup (create as needed)
    my $division = $p->{division} ? $self->app->model('Division')->find_or_create({name => $p->{division}}) : $NULL;
    my $address = $self->app->model('Address')->find_address(city => $p->{city}, state => $p->{state}, country => $p->{country});
    my $gender = $self->app->model('Gender')->find({description => $p->{gender}});

    $p->{age} = undef unless (looks_like_number($p->{age}));

    #create
    my $person;
    # do we have a reg for that event?
    if (my ($reg) = $self->app->model('EventRegistration')->search({event_id => $event->id, bib_no => $p->{bib_no}})) {
      $person = $reg->user->person;
    } elsif (!defined($p->{first_name}) && !defined($p->{last_name}) && !defined($gender) && !defined($p->{age})) {
      $person = $self->app->model('Person')->find_or_create({first_name => 'Unknown', last_name => 'Person'});
    } else {
      $person = $self->app->model('Person')->create({first_name => $p->{first_name}, last_name => $p->{last_name}});
    }
    my ($result, $user_id);
    if ($person->users->count) {
      $user_id = $person->users->first->id;
      my $act_rs = $person->users->first->activities->search({event_id => $event->id});
      if ($act_rs->count) {
        $result = $act_rs->first->result;
      }
    }
    unless ($result) {
      $result = $self->app->model('Result')->create(
        {
          gross_time => $p->{gross_time},
          pace       => $p->{pace},
          net_time   => $p->{net_time}
        }
      );
      $self->app->model('Activity')->create(
        {
          activity_type => $event->event_type->activity_type,
          start_time    => $event->scheduled_start,
          distance      => $event->distance,
          result        => $result,
          event         => $event,
          user_id       => $user_id
        }
      );
    }

    my $overall_group =
      $self->app->model('EventResultGroup')->find_or_create({event => $event, gender_id => $NULL, division_id => $NULL});
    $overall_group->update({count => $p->{overall_count}}) if (defined($p->{overall_count}));
    $self->app->model('EventResult')
      ->create({result => $result, place => $p->{overall_place}, event_result_group => $overall_group});

    if (defined($gender) && defined($p->{gender_place})) {
      my $gender_group =
        $self->app->model('EventResultGroup')->find_or_create({event => $event, gender => $gender, division_id => $NULL});
      $gender_group->update({count => $p->{gender_count}}) if (defined($p->{gender_count}));
      $self->app->model('EventResult')
        ->create({result => $result, place => $p->{gender_place}, event_result_group => $gender_group});
    }

    if ($p->{age} && defined($division) && defined($p->{div_place})) {
      my $div_group =
        $self->app->model('EventResultGroup')->find_or_create({event => $event, gender_id => $NULL, division => $division});
      $div_group->update({count => $p->{div_count}}) if (defined($p->{div_count}));
      $self->app->model('EventResult')->create({result => $result, place => $p->{div_place}, event_result_group => $div_group});
    }

    if ($p->{bib_no} =~ /\D/) {
      print "Truncating " . $p->{bib_no} . "\n";
      $p->{bib_no} =~ s/\D//g;
    }

    my $participant = $self->app->model('Participant')->create(
      {
        result      => $result,
        bib_no      => $p->{bib_no},
        division_id => defined($division) ? $division->id : undef,
        age         => $p->{age},
        person      => $person,
        gender_id   => defined($gender) ? $gender->id : undef,
        address     => $address
      }
    );
  }

  $event->add_missing_gender_groups;
  $event->update_missing_group_counts;
  $event->update_missing_result_paces;

  if (my ($ref) = $self->app->model('EventReference')->search({ref_num => $id, sub_ref_num => $race})) {
    $ref->update({imported => 'Y'});
  }
}

1;
