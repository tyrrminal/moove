package Moove::Model::ResultSet::CumulativeTotal;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures postderef);

sub overall_results ($self, $user_id) {
  return $self->search(
    {
      user_id => $user_id,
      year    => {'=', undef}
    }
  );
}

1;
