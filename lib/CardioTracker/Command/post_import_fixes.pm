package CardioTracker::Command::post_import_fixes;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;

use DateTime;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

has 'description' => 'Address import deficiencies';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self, @args) = @_;

  $self->fix_locations;
  $self->fix_group_counts;
  $self->fix_paces;
  $self->fix_gender_groups;

  $self->fix_bib_nos(2014,'2014 Fisher Cats Mother\'s Day 3k');
}

sub fix_locations {
  my $self=shift;

  my %other_fields = map { $_ => $NULL} qw(street1 street2 zip phone country);
  foreach (
    ['Mansfield' => 'Mansfield', $NULL => 'MA'],
    ['New London' => 'New London', $NULL => 'CT'],
    ['Pemroke' => 'Pembroke', 'MA' => 'MA'],
    ['Westofrd' => 'Westford', 'MA' => 'MA']
  ) {
    my ($nl) = $self->app->model('Location')->find_or_create({ city => $_->[1], state => $_->[3], %other_fields });
    my ($ol) = $self->app->model('Location')->search({ city => $_->[0], state => $_->[2], %other_fields });
    if(defined($ol) && defined($nl)) {
      say "Mapping $_[0] ".$_[2]//''.' to $_[1] $_[3]';
      $ol->participants->update_all({location_id => $nl->id});
      $ol->delete();
    }
  }
}

# Add counts to existing result groups where count is NULL
sub fix_group_counts {
  my $self=shift;

  my $rs = $self->app->model('EventResultGroup')->missing_count;
  while (my $g = $rs->next) {
    say "Updating counts for ".$g->description;
    $g->update_count;
  }
}

# Calculate pace for existing Results where pace is NULL
sub fix_paces {
  my $self=shift;

  say "Updating missing paces";
  my $rs2 = $self->app->model('Result')->needs_pace;
  while (my $r = $rs2->next) {
    $r->update_pace;
  }
}

  # Create missing gender groups and populate relative event results
sub fix_gender_groups {
  my $self=shift;

  my @genders = $self->app->model('Gender')->all;
  my $rs3 = $self->app->model('Event')->is_missing_gender_group;
  while (my $e = $rs3->next) {
    foreach my $g (@genders) {
      say "creating result groups for ".$e->name."/".$g->description;
      $e->create_gender_result_group($g) unless($e->event_result_groups->search({gender_id => $g->id, division_id => $NULL})->count);
    }
  }
}

sub fix_bib_nos {
  my $self=shift;
  my ($year,$event_name) = @_;
  my $event = $self->app->model('Event')->find_event($year,$event_name);

  foreach my $user ($self->app->model('User')->all) {
    if(my ($reg) = $self->app->model('EventRegistration')->search({event_id => $event->id, user_id => $user->id})) {
      my ($p) = $self->app->model('Participant')->search({
        'person.first_name' => $user->person->first_name,
        'person.last_name'  => $user->person->last_name,
        'events.id' => $event->id 
      },{
        join => [
          'person',
          { 'result' => { 'activity' => 'events' } }
        ]
      });

      my $to_delete = $p->person;
      $p->person($user->person);
      $p->bib_no($reg->bib_no);
      $to_delete->delete();
    }
  }
}

1;