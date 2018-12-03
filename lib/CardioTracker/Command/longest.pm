package CardioTracker::Command::longest;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;

use DateTime;
use DCS::Constants qw(:boolean :existence);
use Data::Dumper;
use Mojo::Util 'getopt';
use List::Util qw(sum);
use Array::Utils qw(intersect);

has 'description' => 'Quick test functionality';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self, @args) = @_;

  my $top = 5;
  my $interval = 7;
  getopt(
    \@args,
    'interval:i' => \$interval,
    'top:i' => \$top
  );

  my $me = $self->app->model('User')->find({username => 'digicow'});
  my @activities = map { $_->activity} $me->user_activities->search({
    'activity_type.description' => 'Run'
  },{
    join => { activity => 'activity_type'},
    order_by => 'activity.start_time'
  });

  my @d_sum;
  foreach my $c (@activities) {
    my $d = $c->start_time->clone->subtract(days => $interval-1)->truncate(to => 'day');
    push(@d_sum, [grep { $_->start_time <= $c->start_time && $_->start_time > $d } @activities]);
  }

  my @intermediate = sort { sum(map { $_->distance->normalized_value } @$b) <=> sum(map { $_->distance->normalized_value } @$a) } @d_sum;
  my @sorted_d_sum;

  foreach (@intermediate) {
    my @ids = map { map { $_->id } @$_ } @sorted_d_sum;
    my @new = map { $_->id } @$_;
    unless(intersect(@ids,@new)) {
      push(@sorted_d_sum,$_);
    }
  }

  for (my $i=0;$i<$top;$i++) {
    say $sorted_d_sum[$i]->[0]->start_time->strftime('%F'), " - ",
      $sorted_d_sum[$i]->[-1]->start_time->strftime('%F'),
      " => ", sprintf('%.2f', sum(map { $_->distance->normalized_value } @{$sorted_d_sum[$i]})), " mi";
  }
}

1;
