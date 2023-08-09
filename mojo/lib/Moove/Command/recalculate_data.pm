package Moove::Command::recalculate_data;
use v5.38;
use builtin qw(true);

use Mojo::Base 'Mojolicious::Command';

use DateTime;
use List::Util qw(max);
use Mojo::Util 'getopt';

use experimental qw(builtin);

has 'description' => 'Display information about streaks and gaps';
has 'usage'       => <<"USAGE";
$0 streaks [OPTIONS]
OPTIONS:
  --user      username or user-id to query [required]
  --type      activity type ID(s) to filter on [repeatable]
USAGE

sub run ($self, @args) {
  my ($recalc_pace, $recalc_speed);

  getopt(\@args, 
    'type=s'  => \my @activity_type, 
    'user=s'  => \my $user_id,
    'pace' => \$recalc_pace,
    'speed' => \$recalc_speed,
    'all' => sub { $recalc_pace = true, $recalc_speed = true}
  );

  my $user = $self->app->model('User')->find_user($user_id//'');
  die("'user' is required\n") unless($user);
  my $activities = $user->workouts->related_resultset('activities');
  if(@activity_type) {
    my $activity_type = [map {split(',', $_)} @activity_type];
    $activities = $activities->search({activity_type_id => {-in => $activity_type}})
  }
  my $ars = $activities->related_resultset('activity_result')->search({
    -or => [
      {net_time => {'<>' => undef}},
      {duration => {'<>' => undef}}
    ],
    distance_id => {'<>' => undef},
    -or => [
      {-or => [
        {pace => undef},
        {pace => {'<' => '0:00:10'}}
      ]},
      {-or => [
        {speed => undef},
        {speed => {'>' => 60}},
        {speed => {'<' => 0.1}}
      ]}
    ]
  },{
    order_by => 'start_time'
  });
  while (my $ar = $ars->next) {
    say "Fixing ActivityResult ". $ar->id;
    $ar->recalculate_pace() if($recalc_pace);
    $ar->recalculate_speed() if($recalc_speed);
  }
  
}

1;

__END__
