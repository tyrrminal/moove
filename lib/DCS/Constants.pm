package DCS::Constants;

use base qw(Exporter);
use Modern::Perl;
use Readonly;

our @EXPORT_OK = (
  qw(
    $TRUE
    $FALSE
    $NULL
    $EMPTY
    $SPACE
    $COMMA
    $UNDERSCORE
    $PERIOD
    $DASH
    $COLON
    $NEWLINE
    $SLASH
    $PIPE
  )
);

our %EXPORT_TAGS = (
  boolean => [
    qw(
      $TRUE
      $FALSE
    )
  ],
  existence => [
    qw(
      $NULL
    )
  ],
  symbols => [
    qw(
      $EMPTY
      $SPACE
      $COMMA
      $UNDERSCORE
      $PERIOD
      $DASH
      $COLON
      $NEWLINE
      $SLASH
      $PIPE
    )
  ]
);

Readonly::Scalar our $TRUE  => 1;
Readonly::Scalar our $FALSE => 0;
Readonly::Scalar our $NULL  => undef;

Readonly::Scalar our $EMPTY      => q{};
Readonly::Scalar our $SPACE      => q{ };
Readonly::Scalar our $COMMA      => q{,};
Readonly::Scalar our $UNDERSCORE => q{_};
Readonly::Scalar our $PERIOD     => q{.};
Readonly::Scalar our $DASH       => q{-};
Readonly::Scalar our $COLON      => q{:};
Readonly::Scalar our $NEWLINE    => qq{\n};
Readonly::Scalar our $SLASH      => q{/};
Readonly::Scalar our $PIPE       => q{|};

1;
