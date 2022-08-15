package Moove::Task::ActivityPoint;
use v5.36;

use Mojo::Base 'Mojolicious::Plugin';

use DCS::Constants qw(:symbols);

sub register ($self, $app, $args) {
  $app->minion->add_task(import_activity_points => sub() { });

  $app->minion->add_task(
    copy_activity_points => sub ($job, $destination_activity_id, $sources) {
      my $dest = $app->model('Activity')->find($destination_activity_id);

      foreach my $source_activity_id (split($COMMA, $sources)) {
        my $source = $app->model('Activity')->find($source_activity_id);
        foreach ($source->activity_result->activity_points->all) {
          $dest->activity_result->add_to_activity_points(
            {
              location_id        => $_->location_id,
              timestamp          => $_->timestamp,
              activity_result_id => $dest->activity_result->id,
            }
          );
        }
      }
    }
  );
}

1;
