package CardioTracker::Helper::String_Formatting;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

sub register($self, $app, $args) {

  $app->helper(
    currency_format => sub($self, $num) {
      return sprintf('$%.02f', $num) if(defined($num));
      return '';
    }
  );

  $app->helper(
    pct_format => sub($self, $num) {
      return sprintf('%.02f%%', 100*$num) if(defined($num));
      return '';
    }
  );
  
  $app->helper(
    dec_format => sub($self, $num, $pl) {
      return sprintf("%.0${pl}f", $num) if(defined($num));
      return '';
    }
  )

}

1;
