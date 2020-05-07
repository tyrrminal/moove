package Moove::Model::ResultSet::CumulativeTotal;
use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures);

sub overall_results ($self, $user_id) {
  return $self->search(
    {
      user_id => $user_id,
      year    => {'=', undef}
    }
  );
}

1;
