package Moove::Command::longest;
use v5.38;

use Mojo::Base 'Mojolicious::Command';

use DateTime;
use Data::Dumper;
use Mojo::Util 'getopt';
use List::Util qw(sum);
use Array::Utils qw(intersect);

has 'description' => 'List longest cumulative activity by distance over specified time frame';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  my $act_type = 'Run';
  my $top      = 5;
  my $type     = 'days';
  my $interval = 7;
  getopt(
    \@args,
    'days=i'   => sub {$interval = pop; $type = shift},
    # 'weeks=i'  => sub {$interval = pop; $type = shift},
    # 'months=i' => sub {$interval = pop; $type = shift},
    # 'years=i'  => sub {$interval = pop; $type = shift},
    'top=i'    => \$top,
    'type=i'   => \$act_type,
    'user=s'  => \my $user_id
  );
  my $u = $self->app->model('User')->search({-or => [{username => $user_id},{id => $user_id}]})->first;
  die("User is required\n") unless($u);
  my $activity_type = $self->app->model('ActivityType')->find({id => $act_type});
  die("Type is required\n") unless($activity_type);
  my @activities = $self->app->model('Activity')->for_user($u)->whole->activity_type($activity_type)->ordered;

  my @d_sum;
  foreach my $c (@activities) {
    my $d = $c->start_time->clone->subtract(days => $interval - 1)->truncate(to => 'day');
    push(@d_sum, [grep {$_->start_time <= $c->start_time && $_->start_time > $d} @activities]);
  }

  my @intermediate = sort {
    sum(map {$_->activity_result->normalized_distance->value} @$b) <=> sum(map {$_->activity_result->normalized_distance->value} @$a)
  } @d_sum;
  my @sorted_d_sum;

  foreach (@intermediate) {
    my @ids = map {
      map {$_->id}
        @$_
    } @sorted_d_sum;
    my @new = map {$_->id} @$_;
    unless (intersect(@ids, @new)) {
      push(@sorted_d_sum, $_);
    }
  }

  for (my $i = 0 ; $i < $top ; $i++) {
    say $sorted_d_sum[$i]->[0]->start_time->strftime('%F'), " - ",
      $sorted_d_sum[$i]->[-1]->start_time->strftime('%F'),
      " => ", sprintf('%.2f', sum(map {$_->activity_result->normalized_distance->value} @{$sorted_d_sum[$i]})), " mi";
  }
}

1;
