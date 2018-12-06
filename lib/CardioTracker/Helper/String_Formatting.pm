package CardioTracker::Helper::String_Formatting;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self,$app) = @_;

  $app->helper(
    currency_format => sub {
      my $self=shift;
      my ($num) = @_;

      return sprintf('$%.02f', $num) if(defined($num));
      return '';
    }
  );

  $app->helper(
    pct_format => sub {
      my $self=shift;
      my ($num) = @_;

      return sprintf('%.02f%%', 100*$num) if(defined($num));
      return '';
    }
  );
  
  $app->helper(
    dec_format => sub {
      my $self=shift;
      my ($num,$pl) = (@_,2);

      return sprintf("%.0${pl}f", $num) if(defined($num));
      return '';
    }
  )

}

1;
