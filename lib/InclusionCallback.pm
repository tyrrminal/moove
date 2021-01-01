package InclusionCallback;

use Lingua::EN::Inflect qw(PL);
use DCS::Constants qw(:boolean);

sub new {
  my ($class, %params) = @_;

  return bless({%params}, $class);
}

sub allow_group {
  my $self = shift;
  my ($principal_s) = @_;

  my $principal = PL($principal_s);
  return exists($self->{$principal_s}) unless (exists($self->{$principal}));
  return $self->{$principal}->() if (ref($self->{$principal}) eq 'CODE');
  return $self->{$principal};
}

sub allow {
  my $self = shift;
  my ($principal, $obj) = @_;
  return $FALSE unless (defined($obj));

  return $self->allow_group($principal) unless (exists($self->{$principal}));
  return $self->{$principal}->($obj) if (ref($self->{$principal}) eq 'CODE');
  return $self->{$principal};
}

1;
