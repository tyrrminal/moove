package Moove::Model::ResultSet::CumulativeTotal;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub overall_results ($self, $user_id) {
  return $self->search(
    {
      user_id => $user_id,
      year    => {'=', undef}
    }
  );
}

1;
