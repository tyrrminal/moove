package Moove::Controller::DonorList;
use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;


use HTTP::Status qw(:constants);

use experimental qw(signatures postderef);

sub encode_model_person ($self, $entity) {
  return {
    person => {
      id        => $entity->id,
      firstname => $entity->firstname,
      lastname  => $entity->lastname,
    },
    addresses => $self->encode_model([$self->model('Address')->for_donations_to_user_by_person($self->current_user, $entity)]),
  };
}

sub model_name ($self) {
  return 'Person';
}

sub list ($self) {
  return unless ($self->openapi->valid_input);

  my $fname = $self->validation->param('firstname');
  return $self->render_error(HTTP_BAD_REQUEST, 'firstname parameter is too short (<=2 characters)')
    if (defined($fname) && length($fname) < 3);
  my $lname = $self->validation->param('lastname');
  return $self->render_error(HTTP_BAD_REQUEST, 'lastname parameter is too short (<=2 characters)')
    if (defined($lname) && length($lname) < 3);
  return $self->render_error(HTTP_BAD_REQUEST, 'firstname or lastname is required') unless (defined($fname) || defined($lname));

  my $rs = $self->model('Person')->by_name($fname, $lname)->who_donated_to_user($self->current_user);

  return $self->render(openapi => $self->encode_model([$rs->all]));
}

1;
