package Moove::Model::ResultSet::Event;

use base qw(DBIx::Class::ResultSet);

use DateTime::Format::MySQL;

use DCS::Constants qw(:existence);

sub find_event {
  my $self = shift;
  my ($year, $name) = @_;

  my ($event) = grep {$_->scheduled_start->year == $year} $self->search(
    {
      '-or' => [
        'event_references.referenced_name' => $name,
        'me.name'                          => $name
      ]
    }, {
      join => 'event_references'
    }
  )->all;
  return $event;
}

sub for_user {
  my $self = shift;
  my ($user) = @_;

  return $self->search(
    {
      'event_registrations.user_id' => $user->id
    }, {
      join => 'event_registrations'
    }
  );
}

sub of_type {
  my $self = shift;
  my ($type) = @_;

  return $self->search(
    {
      'event_type.activity_type_id' => $type->id
    }, {
      join => 'event_type'
    }
  );
}

sub on_date {
  my $self = shift;
  my ($date) = @_;

  return $self->search({\['DATE(scheduled_start) = ?' => DateTime::Format::MySQL->format_date($date)],});
}

sub near_datetime {
  my $self = shift;
  my ($date, $minutes_before, $minutes_after) = @_;
  my $before = $date->clone->subtract(minutes => $minutes_before);
  my $after = $date->clone->add(minutes => $minutes_after);

  return $self->search(
    {
      scheduled_start =>
        {-between => [DateTime::Format::MySQL->format_datetime($before), DateTime::Format::MySQL->format_datetime($after)]}
    }
  );
}

sub is_missing_gender_group {
  my $self = shift;

  $self->search(
    \["
    me.id IN (
      SELECT e.id 
      FROM `event` e
      JOIN gender g
      WHERE NOT EXISTS (
        SELECT *
          FROM event_result_group erg
          WHERE erg.event_id=e.id
          AND erg.gender_id=g.id
          AND erg.division_id IS NULL
      )
    )
  "
    ]
  );
}

1;
