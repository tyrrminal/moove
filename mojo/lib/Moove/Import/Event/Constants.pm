package Moove::Import::Event::Constants;
use v5.38;

use base qw(Exporter);

use Readonly;

our @EXPORT_OK = (
  qw(
    $DEFAULT_FIRST_NAME
    $DEFAULT_LAST_NAME
  ),
  qw(
    $AGE
    $BIB_NUMBER
    $CITY
    $COUNTRY
    $STATE
    $DIVISION
    $DIVISION_PLACE
    $DIVISION_PLACE_COUNT
    $FULL_NAME
    $FIRST_NAME
    $LAST_NAME
    $GENDER
    $GENDER_PLACE
    $GENDER_PLACE_COUNT
    $GROSS_TIME
    $NET_TIME
    $OVERALL_PLACE
    $PACE
    $SPEED
    )
);

our %EXPORT_TAGS = (
  event => [
    qw(
      $DEFAULT_FIRST_NAME
      $DEFAULT_LAST_NAME
      )
  ],
  key_fields => [
    qw(
      $AGE
      $BIB_NUMBER
      $CITY
      $COUNTRY
      $STATE
      $DIVISION
      $DIVISION_PLACE
      $DIVISION_PLACE_COUNT
      $FULL_NAME
      $FIRST_NAME
      $LAST_NAME
      $GENDER
      $GENDER_PLACE
      $GENDER_PLACE_COUNT
      $GROSS_TIME
      $NET_TIME
      $OVERALL_PLACE
      $PACE
      $SPEED
      )
  ]
);

Readonly::Scalar our $DEFAULT_FIRST_NAME => 'Unknown';
Readonly::Scalar our $DEFAULT_LAST_NAME  => 'Unknown';

Readonly::Scalar our $AGE                  => 'age';
Readonly::Scalar our $BIB_NUMBER           => 'bib_no';
Readonly::Scalar our $CITY                 => 'city';
Readonly::Scalar our $COUNTRY              => 'country';
Readonly::Scalar our $STATE                => 'state';
Readonly::Scalar our $DIVISION             => 'division';
Readonly::Scalar our $DIVISION_PLACE       => 'div_place';
Readonly::Scalar our $DIVISION_PLACE_COUNT => 'div_place_count';
Readonly::Scalar our $FULL_NAME            => 'name';
Readonly::Scalar our $FIRST_NAME           => 'first_name';
Readonly::Scalar our $LAST_NAME            => 'last_name';
Readonly::Scalar our $GENDER               => 'gender';
Readonly::Scalar our $GENDER_PLACE         => 'gender_place';
Readonly::Scalar our $GENDER_PLACE_COUNT   => 'gender_place_count';
Readonly::Scalar our $GROSS_TIME           => 'gross_time';
Readonly::Scalar our $NET_TIME             => 'net_time';
Readonly::Scalar our $OVERALL_PLACE        => 'overall_place';
Readonly::Scalar our $PACE                 => 'pace';
Readonly::Scalar our $SPEED                => 'speed';

1;
