package CardioTracker::Command::post_activities_fixes;
use Mojo::Base 'Mojolicious::Command', -signatures;

use DateTime;
use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

use CardioTracker::Model::Result::Result;
use DateTime::Format::Duration;

use CardioTracker::Import::Helper::TextBalancedFix;

has 'description' => 'Quick test functionality';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run($self, @args) {
  foreach my $u ($self->app->model('User')->all) {
    my @activities = $self->app->model('Activity')->for_user($u)->ordered->all;

    my $fmt = DateTime::Format::Duration->new(pattern => '%T', normalize => $TRUE);

    my $prev;
    my $limit = DateTime::Duration->new(minutes => 15);
    foreach my $act (@activities) {
      next unless(defined($prev));
      #next if(defined($act->whole_activity));
      next if(defined($act->event) || defined($prev->event));
      next unless($prev->activity_type->id == $act->activity_type->id);
      my $diff = $act->start_time - $prev->end_time;
      if(DateTime::Duration->compare($limit, $diff) > 0) {
        say $act->start_time->strftime('%F'), " ", $act->activity_type->description, " ", $fmt->format_duration($diff);

        my $d = $self->app->model('Distance')->find_or_create_from_miles($prev->distance->normalized_value + $act->distance->normalized_value);
        my $hr = defined($act->result->heart_rate && defined($prev->result->heart_rate)) ? ($act->result->heart_rate*$act->result->net_time->in_units('minutes') + $prev->result->heart_rate*$prev->result->net_time->in_units('minutes'))/($act->result->net_time->in_units('minutes')+$prev->result->net_time->in_units('minutes')) : $NULL;
        my $t = $act->result->net_time + $prev->result->net_time;
        my $r = $self->app->model('Result')->create({
          gross_time => $act->end_time - $prev->start_time,
          net_time   => $t,
          pace       => CardioTracker::Model::Result::Result::_calculate_pace($t, $d),
          heart_rate => $hr
        });

        my $w = $self->app->model('Activity')->create({
          activity_type => $act->activity_type,
          user_id       => $u->id,
          start_time    => $prev->start_time,
          distance      => $d,
          result        => $r,
          event_id      => $NULL,
          note          => join("\n\n", $prev->note, $act->note),
        });

        $prev->whole_activity($w);
        $prev->update();
        $act->whole_activity($w);
        $act->update();
      }
    } continue {
      $prev = $act;
    }
  }
}

1;
