package Moove::Controller::Role::ModelEncoding::UserEventActivity;
use v5.36;

use Role::Tiny;
with 'Moove::Controller::Role::ModelEncoding::Donation';

use List::Util qw(sum);

sub encode_model_usereventactivity ($self, $entity) {
  my $reg         = $entity->event_registration;
  my $participant = $reg->event_participants->first;
  my $ea          = $reg->event_activity;
  my $event       = $ea->event;

  my $r = {
    id                 => $entity->id,
    eventActivity      => $self->encode_model($ea),
    registrationNumber => $reg->registration_number,
    fee                => $entity->registration_fee,
    registeredDate     => $self->encode_date($entity->date_registered),
    visibilityTypeID   => $entity->visibility_type_id,
    user               => $self->encode_model($entity->user),
  };
  $r->{activity}   = $self->encode_model($entity->activity) if (defined($entity->activity));
  $r->{placements} = $self->encode_model([$participant->event_placements->all])
    if (defined($participant) && $participant->event_placements->count);
  if (my $fr = $self->encode_model_usereventactivity_fundraising($entity)) {
    $r->{fundraising} = $fr;
  }
  if (ref($self->resultset) =~ /UserEventActivity/) {
    $r->{nav} = {
      prev => $self->encode_model_simple(
        $self->resultset->before($entity)->for_user($entity->user)->visible_to($self->current_user)->first
      ),
      next => $self->encode_model_simple(
        $self->resultset->after($entity)->for_user($entity->user)->visible_to($self->current_user)->first
      ),
    };
    foreach (qw(next prev)) {
      delete($r->{nav}->{$_}) unless (defined($r->{nav}->{$_}));
    }
  }
  return $r;
}

sub encode_model_user ($self, $entity) {
  return {
    id       => $entity->id,
    username => $entity->username
  };
}

sub encode_model_simple ($self, $entity) {
  return undef unless (defined($entity));
  return {
    id   => $entity->id,
    name => $entity->name
  };
}

sub encode_model_usereventactivity_fundraising ($self, $entity) {
  my $r;
  if (defined($entity->fundraising_requirement)) {
    $r = {
      minimum  => $entity->fundraising_requirement,
      received => sum(map {$_->amount} $entity->donations->all),
    };
    if ($entity->user->id == $self->current_user->id) {
      $r->{donations} = $self->encode_model([$entity->donations->all]);
    }
  }
  return $r;
}

1;
