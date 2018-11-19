package CardioTracker::Model::ResultSet::Distance;
use base qw(DBIx::Class::ResultSet);

use Modern::Perl;

sub find_or_create_from_miles {
  my $self=shift;
  my ($miles)=@_;

  foreach (map { [$miles/$_->conversion_factor, $_] } $self->result_source->schema->resultset('UnitOfMeasure')->search({conversion_factor => {'!=' => 1}})) {
    my ($v,$u) = @$_;
    my $d = $self->search({
      value => int($v*100)/100,
      uom => $u->id
    })->first;
    return $d if(defined($d));

    return $self->find_or_create({ value => $miles, uom => 1 });
  }

}

1;
