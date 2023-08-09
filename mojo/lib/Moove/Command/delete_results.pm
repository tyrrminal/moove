package Moove::Command::delete_results;
use v5.38;

use Mojo::Base 'Mojolicious::Command';

use Mojo::Util 'getopt';
use DateTime;
use DateTime::Format::MySQL;
use List::Util qw(reduce uniq sum);

use Moove::Import::Helper::TextBalancedFix;

has 'description' => 'Combine two or more activities into a single activiity';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  my ($event_id);
  getopt(\@args, 'id=i' => \$event_id);

  $self->delete_results($event_id);
}

sub delete_results ($self, $event_id) {
  my $event      = $self->app->model('Event')->find($event_id);
  my @activities = $self->app->model('Activity')->search({event_id => $event_id})->all;
  foreach my $activity (@activities) {
    my $result = $activity->result;
    $activity->delete;
    if ($result) {
      $result->delete_related('event_results');
      $result->delete_related('participants');
      $result->delete;
    }
  }

  $event->delete_related('event_result_groups');
  foreach my $ref ($event->event_references) {
    $ref->update({imported => 'N'});
  }
}

1;
