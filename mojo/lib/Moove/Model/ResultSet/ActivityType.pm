package Moove::Model::ResultSet::ActivityType;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub lookup ($self, $type, $has_map) {
  return $type if (ref($type) eq 'Moove::Model::Result::ActivityType');

  $self->search(
    {
      'base_activity_type.description' => $type,
      'activity_context.has_map'       => $has_map ? 'Y' : 'N',
    }, {
      join     => ['activity_context', 'base_activity_type'],
      order_by => 'me.id'
    }
  )->first;
}

1;
