package CardioTracker::Command::import_events;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;
use Mojo::Util 'getopt';

use Text::CSV_XS;

use DCS::Constants qw(:boolean :existence);

has 'description' => 'Import a list of events';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self, @args) = @_; 

  getopt(
    \@args,
    'file:s' => \my $filename
  );

  my $csv = Text::CSV_XS->new ({ binary => $TRUE, auto_diag => $TRUE });
  open(my $F, '<:encoding(utf8)', $filename) or die($!);
  my @col_map = @{$csv->getline($F)};
  while(my $row = $csv->getline($F)) {
    my %r;
    @r{@col_map} = @$row;
    my $v = \%r;

    my $act_type = $self->app->model('ActivityType')->find({description => $v->{activity_type}});
    my $type = $self->app->model('EventType')->find({description => $v->{event_type}});
    my $uom = $self->app->model('UnitOfMeasure')->find({abbreviation => $v->{distance_l}});
    my $distance = $self->app->model('Distance')->find_or_create({value => $v->{distance_v}, uom => $uom->id});
    my $location = $self->app->model('Location')->find_location(%r);

    my $event = $self->app->model('Event')->create({
      name => $v->{name},
      scheduled_start => $v->{date},
      event_type_id => $type->id,
      distance => $distance,
      location => $location
    });

    my $reg = $self->app->model('EventRegistration')->create({
      event => $event,
      user_id => $v->{user_id},
      fee => $v->{fee} eq '' ? $NULL : $v->{fee},
      registered => $v->{registered},
      bib_no => $v->{bib_no} || $NULL
    });

    if($v->{reference_type}) {
      my $ert = $self->app->model('EventReferenceType')->find({description => $v->{reference_type}});
      $self->app->model('EventReference')->create({
        event => $event,
        event_reference_type => $ert,
        referenced_name => $v->{event_name},
        ref_num => $v->{reference_id},
        sub_ref_num => $v->{reference_sub_id} || $NULL
      });
    }
  }
}

1;
