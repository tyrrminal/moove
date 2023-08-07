package Moove::Model::ResultSet::UserNominalActivity;
use v5.36;

use base qw(DBIx::Class::ResultSet);

use DateTime::Format::MySQL;
use List::Util qw(sum);

sub for_type($self, @activity_types) {
  $self->search({
    activity_type_id => {-in => [map { ref($_) ? $_->id : $_ } @activity_types]}
  })
}

sub in_range($self, $start, $end) {
  my $range = [DateTime::Format::MySQL->format_date($start), DateTime::Format::MySQL->format_date($end)];
  $self->search({
    -or => [
      {start_date => {-between => $range}},
      {end_date   => {-between => $range}},
      { -and => [
        { start_date => { '<=' => $range->[0] } },
        { end_date   => { '>'  => $range->[1] } }
      ]
      }
    ]
  })
}

sub nominal_distance_in_range($self, $start, $end) {
  $self->result_source->schema->resultset('Distance')->distance_sum(map { $_->nominal_distance_in_range($start, $end) } $self->all);
}

1;
