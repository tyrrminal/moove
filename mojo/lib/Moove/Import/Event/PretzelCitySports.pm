package Moove::Import::Event::PretzelCitySports;
use v5.38;
use builtin qw(true);

use Moose;
with 'Moove::Import::Event::Base';

use JSON::Validator::Joi qw(joi);
use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);

use experimental qw(builtin);

use DCS::Constants                  qw(:symbols);
use Moove::Import::Event::Constants qw(:event);

Readonly::Hash my %COL_MAP => (
  PLACE  => 'overall_place',
  TIME   => 'gross_time',
  'BIB#' => 'bib_no',
  LAST   => 'last_name',
  FIRST  => 'first_name',
  STATE  => 'state',
  SEX    => 'gender',
  AGE    => 'age',
  AWARD  => undef,
  DIV    => 'division',
);

has field_map => (
  is  => 'rw',
  isa => 'ArrayRef[Str|Undef]'
);

sub _build_import_param_schemas ($class) {
  return {
    event         => JSON::Validator->new()->schema(),
    eventactivity => JSON::Validator->new()->schema()
  };
}

sub import_request_fields ($self) {return [qw(data)]}

sub url {'https://www.pretzelcitysports.com/race-results/'}

sub _build_results ($self) {
  my $data = $self->resolve_field_value('data');

  my @lines = split(/\n/, $data);
  my $head  = shift(@lines);
  $self->field_map([map {$COL_MAP{$_}} split(/\t/, $head)]);

  my @results;
  while (my $row = shift(@lines)) {
    push(@results, $self->make_participant($row));
  }

  return [@results];
}

sub make_participant ($self, $row) {
  my %p;
  my @values = split(/\t/, $row);
  my $i      = 0;
  foreach my $v (@values) {
    my $key = $self->field_map->[$i];
    $p{$key} = $v if (defined($key));
    $i++;
  }
  normalize_times(\%p);
  return \%p;
}

1;
