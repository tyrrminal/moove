package Moove::Controller::Donation;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Create';
with 'Moove::Controller::Role::ModelEncoding::UserEventActivity';

use HTTP::Status qw(:constants);

sub decode_model ($self, $data) {
  if (defined($data->{person}) && defined($data->{person}->{id})) {
    $data->{person_id} = $data->{person}->{id};
    delete($data->{person});
  }
  if (defined($data->{address}) && defined($data->{address}->{id})) {
    $data->{address_id} = $data->{address}->{id};
    delete($data->{address});
  }
  $data->{user_event_activity_id} = $self->validation->param('userEventActivityID');

  return $data;
}

sub encode_model_on_create ($self, $entity) {
  return $self->encode_model_usereventactivity_fundraising($entity->user_event_activity);
}

1;
