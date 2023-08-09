package Moove::Controller::Meta;
use v5.38;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'Moove::Controller::Role::ModelEncoding::ActivityType',
  'Moove::Controller::Role::ModelEncoding::EventType',
  'Moove::Controller::Role::ModelEncoding::ExternalDataSource',
  'Moove::Controller::Role::ModelEncoding::UnitOfMeasure';

use DCS::Util::NameConversion qw(camel_lower_to_upper camel_plural_to_singular);

sub list ($self) {
  return unless $self->openapi->valid_input;

  my $r = {};
  foreach (qw(activityTypes eventTypes unitOfMeasure externalDataSources visibilityTypes)) {
    if ($self->validation->param($_) || $self->validation->param('all')) {
      my $model_name = camel_lower_to_upper(camel_plural_to_singular($_));
      $r->{$_} = [$self->model($model_name)->all];
    }
  }

  return $self->render(openapi => $self->encode_model($r));
}

1;
