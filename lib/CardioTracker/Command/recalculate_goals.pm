package CardioTracker::Command::recalculate_goals;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Util 'getopt';
use DateTime;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean);

has 'description' => 'Recalculate goal activities for a user';
has 'usage' => <<"USAGE";
$0 --user [id|name]
OPTIONS:
  --user      user_id or username to recalc goals for
USAGE

sub run($self, @args) {
  getopt(
    \@args,
    'user=s' => \(my $user_id),
  );

  my $user = $self->app->model('User')->find_user($user_id);

  foreach my $type ($self->app->model('ActivityType')->all) {
    foreach my $goal ($self->app->model('UserGoal')->for_user($user)->of_type($type)) {
      $goal->recalculate();
    }
  }
}

1;
