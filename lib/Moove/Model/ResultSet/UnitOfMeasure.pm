package Moove::Model::ResultSet::UnitOfMeasure;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

sub normalization_unit {
  my $self=shift;
  my ($dimension) = @_;
  return $self->search(
    {
      'dimension.description' => $dimension,
      conversion_factor       => 1
    }, {
      join => 'dimension'
    }
  )->first;
}

1;
