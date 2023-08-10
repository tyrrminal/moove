package Moove::Controller::Role::ModelEncoding::UserEventActivity;
use v5.38;

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
    registrationFee    => $entity->registration_fee,
    dateRegistered     => $self->encode_date($entity->date_registered),
    visibilityTypeID   => $entity->visibility_type_id,
    user               => $self->encode_model($entity->user),
    nav                => [],
  };
  $r->{activity}    = $self->encode_model($entity->activity) if (defined($entity->activity));
  $r->{eventResult} = $self->encode_model_result($ea->event_type->activity_type, $participant->event_result)
    if ($participant && $participant->event_result);
  $r->{placements} = $self->encode_model([$participant->event_placements->all])
    if (defined($participant) && $participant->event_placements->count);
  if (my $fr = $self->encode_model_usereventactivity_fundraising($entity)) {
    $r->{fundraising} = $fr;
  }
  
  push($r->{nav}->@*, $self->encode_model_usereventactivity_navigation($entity, $self->resultset)); 
  push($r->{nav}->@*, $self->encode_model_usereventactivity_navigation($entity, scalar $self->resultset->in_group($event->event_group_id), 'group'));
  foreach my $ese ($event->event_series_events) {
    push($r->{nav}->@*, $self->encode_model_usereventactivity_navigation($entity, scalar $self->resultset->in_group($ese->event_series_id), $ese->event_series->description));
  }

  return $r;
}

sub encode_model_usereventactivity_navigation($self, $entity, $rs, $description = undef) {
  return unless (ref($self->resultset) =~ /UserEventActivity/);
  my $nav;
  if(my $prev = $rs->before($entity)->for_user($entity->user)->visible_to($self->current_user)->first) {
    $nav->{prev} = $self->encode_model_simple($prev)
  }
  if(my $next = $rs->after($entity)->for_user($entity->user)->visible_to($self->current_user)->first) {
    $nav->{next} = $self->encode_model_simple($next)
  }
  return unless(grep { defined } keys($nav->%*));
  return {$nav->%*, description => $description};
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
    name => $entity->name,
    year => $entity->event_registration->event_activity->event->year,
  };
}

sub encode_model_usereventactivity_fundraising ($self, $entity) {
  my $r;
  if (defined($entity->fundraising_requirement)) {
    $r = {
      minimum  => $entity->fundraising_requirement,
      received => sum(0,map {$_->amount} $entity->donations->all),
    };
    if ($entity->user->id == $self->current_user->id) {
      $r->{donations} = $self->encode_model([$entity->donations->all]);
    }
  }
  return $r;
}

1;
