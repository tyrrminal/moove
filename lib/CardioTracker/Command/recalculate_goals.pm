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

  my @goals = $self->app->model('UserGoal')->for_user($user);

  print "--- PRs ---\n";
  foreach my $goal (grep { $_->is_pr } @goals) {
    $goal->recalculate();
        
    print $goal->goal->name;
    print ": ---" and next unless($goal->is_fulfilled);
    print "\n";
    foreach ($goal->history) {
      print "  ". $_->get_goal_description .' (' . $_->date->strftime('%F') . ")\n";
    }
  }

  print "--- Achievements ---\n";
  foreach my $goal (grep { !$_->is_pr } @goals) {
    $goal->recalculate();
    print "---------------------------\n";  

    print $goal->goal->name .": ".( $goal->is_fulfilled ? ($goal->get_goal_description .' (' . $goal->user_goal_fulfillments->most_recent->date->strftime('%F') . ")") : "---") . "\n";
  }
}

1;
