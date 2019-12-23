package Moove::Command::recalculate_goals;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Util 'getopt';
use DateTime;

use Moove::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean);

has 'description' => 'Recalculate goal activities for a user';
has 'usage'       => <<"USAGE";
$0 --user [id|name]
OPTIONS:
  --user      user_id or username to recalc goals for
USAGE

sub run ($self, @args) {
  getopt(\@args, 'user=s' => \(my $user_id),);

  my $user = $self->app->model('User')->find_user($user_id);

  my @goals = $self->app->model('UserGoal')->for_user($user);

  print "--- PRs ---\n";
  foreach my $goal (grep {$_->goal->is_pr} @goals) {
    $goal->recalculate();

    print $goal->goal->name;
    print ": ---" and next unless ($goal->is_fulfilled);
    print "\n";
    foreach ($goal->history) {
      print "  " . $_->get_goal_description . ' (' . $_->date->strftime('%F') . ")\n";
    }
  }

  print "\n--- Achievements ---\n";
  foreach my $goal (grep {!$_->goal->is_pr} @goals) {
    $goal->recalculate();

    print $goal->goal->name . ":";
    if ($goal->is_fulfilled) {
      print "\n";
      print "  " . $goal->get_goal_description . ' (' . $goal->user_goal_fulfillments->most_recent->date->strftime('%F') . ")";
    } else {
      print " ---";
    }
    print "\n";
  }
}

1;
