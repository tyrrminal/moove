package CardioTracker::Model::ResultSet::Event;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:boolean :existence);

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
