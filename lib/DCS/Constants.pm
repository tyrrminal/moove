package DCS::Constants;

use base qw(Exporter);
use Modern::Perl;
use Readonly;

our @EXPORT = (
  qw(
    $TRUE
    $FALSE
    $NULL
  )
);

our @EXPORT_OK = (
  qw(
    $TRUE
    $FALSE
    $NULL
    $CONF_FROM_ENV
    $CONF_FROM_FILE
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
  config => [
    qw(
      $CONF_FROM_ENV
      $CONF_FROM_FILE
    )
  ]
);

Readonly::Scalar our $TRUE  => 1;
Readonly::Scalar our $FALSE => 0;
Readonly::Scalar our $NULL  => undef;

Readonly::Scalar our $CONF_FROM_ENV   => q(env);
Readonly::Scalar our $CONF_FROM_FILE  => q(conf);

1;
