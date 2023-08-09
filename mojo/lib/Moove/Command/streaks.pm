package Moove::Command::streaks;
use v5.38;

use Mojo::Base 'Mojolicious::Command';

use DateTime;
use Lingua::EN::Inflect qw(PL);
use List::Util qw(max);
use Mojo::Util 'getopt';

has 'description' => 'Display information about streaks and gaps';
has 'usage'       => <<"USAGE";
$0 streaks [OPTIONS]
OPTIONS:
  --user      username or user-id to query [required]
  --type      activity type ID(s) to filter on [required, repeatable]
  --longest   display information about the sequentially longest streaks only
  --start     YYYY-MM-DD
  --end       YYYY-MM-DD
USAGE

sub run ($self, @args) {
  getopt(\@args, 
    'start=s' => \my $start, 
    'end=s'   => \my $end, 
    'longest' => \my $longest, 
    'type=s'  => \my @activity_type, 
    'user=s'  => \my $user_id
  );

  my $user = $self->app->model('User')->find_user($user_id//'');
  die("'user' is required\n") unless($user);
  my $activities = $user->workouts->related_resultset('activities');
  die("'type' is required\n") unless(@activity_type);
  my $activity_type = [map {split(',', $_)} @activity_type];
  $activities = $activities->search({
    activity_type_id => {-in => $activity_type},
    activity_result_id => {'<>' => undef},
    whole_activity_id => undef
  },{
    join => 'activity_result',
    order_by => 'activity_result.start_time'
  });
  if($start) {
    $activities = $activities->search({
      'activity_result.start_time' => {'>' => $start}
    })
  }
  if($end) {
    $activities = $activities->search({
      'activity_result.start_time' => {'<' => $end}
    })
  }

  my @streaks;

  my @current = ($activities->next);
  while(my $act = $activities->next) {
    my $ss = $current[0];
    my $prev = $current[$#current];
    my $d = $act->start_date->delta_days($prev->start_date)->in_units('days');
    if($d > 1) {
      push(@streaks, { start => $ss->start_date, days => $prev->start_date->delta_days($ss->start_date)->in_units('days')+1, type => 'streak' });
      push(@streaks, { start => $prev->start_date->clone->add(days => 1), days => $d-1, type => 'gap' });
      @current = ();
    }
    push(@current, $act);
  }
  my $t = DateTime->today(time_zone => 'local');
  push(@streaks, { start => $current[0]->start_date, days => $current[$#current]->start_date->delta_days($current[0]->start_date)->days+1, type => 'streak' });
  push(@streaks, { start => $current[$#current]->start_date, days => $t->delta_days($current[$#current]->start_date)->days-1, type => 'gap' }) if($current[$#current]->start_date < $t);

  if($longest) {
    foreach my $type (qw(streak gap)) {
      say ucfirst($type);
      my @subset = grep { $_->{type} eq $type } @streaks;
      my @gt;
      foreach my $streak (@subset) {
        my $pm = max(map {$_->{days}} @gt) // 0;
        if($streak->{days} > $pm) {
          push(@gt, $streak);
          say '  [' . $streak->{start}->strftime('%F') . '] ' . $streak->{days} . PL(' day', $streak->{days});
        }
      }
    }
  }
}

1;

__END__
