package Moove::Task::EventResult;
use v5.38;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(class_to_path);

use DCS::Constants qw(:symbols);

sub register ($self, $app, $args) {
  $app->minion->add_task(
    import_event_results => sub ($job, $event_activity_id, $import_fields) {
      $job->note(progress => 0);
      my $event_activity = $job->app->model('EventActivity')->find($event_activity_id);
      my $event          = $event_activity->event;
      my $edc            = $event->external_data_source;
      my $class          = $event_activity->all_import_params->{custom_class} // $edc->import_class;
      require(class_to_path($class));
      my $importer = $class->new(import_params => $event_activity->all_import_params, import_fields => $import_fields);

      # BEGIN LRP
      my @participants = $importer->results->@*;
      $job->note(progress => $job->info->{notes}->{progress} + 25);
      # END LRP
      return unless (@participants);

      my $edc_overrides = $job->app->conf->import_overrides->event_results->{$edc->name};
      my $overrides     = $edc_overrides ? $edc_overrides->{$event_activity->qualified_external_identifier} : {};

      # BEGIN LRP
      $event_activity->delete_results();
      $event_activity->update({entrants => $importer->total_entrants});
      foreach my $p (@participants) {
        apply_overrides($overrides, $p);
        $event_activity->add_participant($p);
        $job->note(progress => $job->info->{notes}->{progress} + 70 / @participants);
      }
      $job->note(progress => 95);
      $event_activity->update_missing_result_paces;
      $job->note(progress => $job->info->{notes}->{progress} + 2);
      foreach my $g ($job->app->model("Gender")->all) {
        $event_activity->add_placements_for_gender($g);
        $job->note(progress => $job->info->{notes}->{progress} + 1);
      }
      # END LRP
      $job->note(progress => 100);
    }
  );
}

sub apply_overrides ($overrides, $record) {
  foreach my $key (keys($overrides->%*)) {
    my $replacements = $overrides->{$key};
    foreach my $v (keys($replacements->%*)) {
      $record->{$key} = $replacements->{$v} if ($record->{$key} eq $v);
    }
  }
}

1;
