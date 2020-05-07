package DCS::NameConversion;

use Exporter qw(import);

use Lingua::EN::PluralToSingular qw(to_singular);
use List::Util qw(reduce);
use DCS::Constants qw(:symbols);
use Readonly;

use experimental qw(signatures);

our @EXPORT_OK = qw(
  camel_lower_to_upper
  camel_plural_to_singular
  camel_to_snake
  snake_to_camel
  convert_hash_keys
  );

Readonly::Scalar my $SNAKE_BOUNDARY => $UNDERSCORE;
Readonly::Scalar my $CAMEL_BOUNDARY => qr/(?<=[[:lower:]])(?=[[:upper:]])/;    #positive lookahead to uppercase letter

sub camel_lower_to_upper($str) {
  return ucfirst($str);
}

sub camel_plural_to_singular($str) {
  my @p   = split($CAMEL_BOUNDARY, $str);
  my $s   = to_singular(pop(@p));
  my $out = join($EMPTY, @p, $s);
  return $out;
}

sub snake_to_camel($str) {
  my @p = split($SNAKE_BOUNDARY, $str);
  return reduce {$a . ($b eq 'id' ? uc($b) : ucfirst($b))} @p;
}

sub camel_to_snake($str) {
  my @p = split($CAMEL_BOUNDARY, $str);
  return lc(join($SNAKE_BOUNDARY, @p));
}

sub convert_hash_keys {
  my $cb = pop(@_);
  my %h  = @_;
  foreach (keys(%h)) {
    $h{$cb->($_)} = delete($h{$_});
  }
  return %h;
}

1;
