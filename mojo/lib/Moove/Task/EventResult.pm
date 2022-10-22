package Moove::Task::EventResult;
use v5.36;

use Mojo::Base 'Mojolicious::Plugin';

use DCS::Constants qw(:symbols);

sub register ($self, $app, $args) {
  $app->minion->add_task(
    import_event_results => sub ($job, $event_activity_id) {
      my $event_activity = $job->app->model('EventActivity')->find($event_activity_id);
      my $event          = $event_activity->event;
      my $edc            = $event->external_data_source;
      my $class          = $edc->import_class;
      require(class_to_path($class));
      my $importer = $class->new(event_id => $event->external_identifier, race_id => $event_activity->external_identifier);

      my @participants = $importer->results->@*;
      return unless (@participants);

      my $edc_overrides = $job->app->conf->import_overrides->event_results->{$edc->name};
      my $overrides     = $edc_overrides ? $edc_overrides->{$event_activity->qualified_external_identifier} : {};

      $event_activity->delete_results();
      $event_activity->update({entrants => $importer->total_entrants});
      foreach my $p (@participants) {
        process_overrides($overrides, $p);
        $event_activity->add_participant($p);
      }
      $event_activity->update_missing_result_paces;
      foreach my $g ($job->app->model("Gender")->all) {
        $event_activity->add_placements_for_gender($g);
      }
    }
  );
}

sub process_overrides ($overrides, $record) {
  foreach my $key (keys($overrides->%*)) {
    my $replacements = $overrides->{$key};
    foreach my $v (keys($replacements->%*)) {
      $record->{$key} = $replacements->{$v} if ($record->{$key} eq $v);
    }
  }
}

1;
