package Moove::Controller::Meta;
use Mojo::Base 'DCS::API::Base::ModelController';
use Role::Tiny::With;

use DCS::NameConversion qw(camel_lower_to_upper camel_plural_to_singular);

use experimental qw(signatures);

sub list($self) {
  return unless $self->openapi->valid_input;

  my $r = {};
  foreach (qw(activityTypes eventTypes eventReferenceTypes dimensions unitOfMeasure)) {
    if ($self->validation->param($_) || $self->validation->param('all')) {
      my $model_name = camel_lower_to_upper(camel_plural_to_singular($_));
      $r->{$_} = [$self->model($model_name)->all];
    }
  }

  return $self->render(openapi => $self->encode_model($r));
}

1;
