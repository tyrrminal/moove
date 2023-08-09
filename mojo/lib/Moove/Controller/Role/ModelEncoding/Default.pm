package Moove::Controller::Role::ModelEncoding::Default;
use v5.38;

use Role::Tiny;

sub encode_model_address ($self, $address) {
  my %r = $self->encode_simple_model($address)->%*;
  return {map {$_ => $r{$_}} grep {defined($r{$_})} keys(%r)};
}

sub encode_model_cumulativetotal ($self, $total) {
  return {
    activityTypeID => $total->activity_type_id,
    unitID         => $total->uom->id,
    distance       => $total->distance,
    year           => $total->year,
  };
}

sub encode_model_distance ($self, $distance) {
  return {
    value           => $distance->value,
    unitOfMeasureID => $distance->unit_of_measure->id,
  };
}

sub encode_model_person ($self, $person) {
  return {
    id        => $person->id,
    lastname  => $person->lastname,
    firstname => $person->firstname,
  };
}

sub encode_model_unitofmeasure ($self, $uom) {
  return {
    id                  => $uom->id,
    label               => $uom->uom,
    abbreviation        => $uom->abbreviation,
    normalizationFactor => $uom->conversion_factor,
  };
}

sub encode_model_user ($self, $user) {
  return {
    id       => $user->id,
    username => $user->username,
    person   => $self->encode_model($user->person),
  };
}


1;
