package CardioTracker::Command::post_results_fixes;
use Mojo::Base 'Mojolicious::Command', -signatures;

use DateTime;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

has 'description' => 'Address import deficiencies';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  $self->fix_addresss;
  $self->fix_events_results;

  $self->fix_bib_nos(2014, '2014 Fisher Cats Mother\'s Day 3k');
}

sub fix_addresss {
  my $self = shift;

  my %other_fields = map {$_ => $NULL} qw(street1 street2 zip phone country);
  foreach (
    ['Mansfield'  => 'Mansfield',  $NULL => 'MA'],
    ['New London' => 'New London', $NULL => 'CT'],
    ['Pemroke'    => 'Pembroke',   'MA'  => 'MA'],
    ['Westofrd'   => 'Westford',   'MA'  => 'MA']
    )
  {
    my ($nl) = $self->app->model('Address')->find_or_create({city => $_->[1], state => $_->[3], %other_fields});
    my ($ol) = $self->app->model('Address')->search({city => $_->[0], state => $_->[2], %other_fields});
    if (defined($ol) && defined($nl)) {
      say "Mapping $_[0] " . $_[2] // '' . ' to $_[1] $_[3]';
      $ol->participants->update_all({address_id => $nl->id});
      $ol->delete();
    }
  }
}

# Add counts to existing result groups where count is NULL
# Create missing gender groups and populate relative event results
# Calculate pace for existing Results where pace is NULL
sub fix_events_results {
  my $self = shift;

  foreach my $e ($self->app->model('Event')->all) {
    say "fixing event " . $e->description;
    say "  gender groups";
    $e->add_missing_gender_groups;
    say "  group counts";
    $e->update_missing_group_counts;
    say "  paces";
    $e->update_missing_result_paces;
  }
}

sub fix_bib_nos ($self, $year, $event_name) {
  my $event = $self->app->model('Event')->find_event($year, $event_name);

  foreach my $user ($self->app->model('User')->all) {
    if (my ($reg) = $self->app->model('EventRegistration')->search({event_id => $event->id, user_id => $user->id})) {
      my ($p) = $self->app->model('Participant')->search(
        {
          'person.first_name' => $user->person->first_name,
          'person.last_name'  => $user->person->last_name,
          'event.id'          => $event->id
        }, {
          join => ['person', {'result' => {'activities' => 'event'}}]
        }
      );

      my $to_delete = $p->person;
      unless ($to_delete->id == $user->person->id) {
        $p->update(
          {
            person_id => $user->person->id,
            bib_no    => $reg->bib_no
          }
        );
        $to_delete->delete();
      }
    }
  }
}

1;
