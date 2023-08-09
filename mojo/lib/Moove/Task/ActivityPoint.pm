package Moove::Task::ActivityPoint;
use v5.38;

use Mojo::Base 'Mojolicious::Plugin';
use Module::Util qw(module_path);

use DCS::Constants qw(:symbols);

sub register ($self, $app, $args) {
  $app->minion->add_task(
    import_activity_points => sub ($job, $import_class, $path, $activity_id, $activity_result_id) {
      my $activity_result = $app->model('ActivityResult')->find($activity_result_id);
      die("Specified activity result id does not exist\n") unless (defined($activity_result));

      require(module_path($import_class)) or die("No such import class '$import_class'\n");
      die("'$path' does not exist or is not readable\n") unless (-f $path && -r _);
      my $importer = $import_class->new(file => $path);

      my $points = $importer->get_activity_location_points($activity_id);
      foreach my $ap ($points->@*) {
        my $location = $app->model('Location')->create(
          {
            latitude  => $ap->{lat},
            longitude => $ap->{lon}
          }
        );
        $activity_result->add_to_activity_points(
          {
            activity_result_id => $activity_result->id,
            timestamp          => $ap->time_datetime,
            location_id        => $location->id
          }
        );
      }
    }
  );

  $app->minion->add_task(
    copy_activity_points => sub ($job, $destination_activity_id, $sources) {
      my $dest = $app->model('Activity')->find($destination_activity_id);

      foreach my $source_activity_id (split($COMMA, $sources)) {
        my $source = $app->model('Activity')->find($source_activity_id);
        foreach ($source->activity_result->activity_points->all) {
          $dest->activity_result->add_to_activity_points(
            {
              activity_result_id => $dest->activity_result->id,
              timestamp          => $_->timestamp,
              location_id        => $_->location_id,
            }
          );
        }
      }
    }
  );
}

1;
