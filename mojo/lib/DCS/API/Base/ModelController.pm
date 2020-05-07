package DCS::API::Base::ModelController;
use Mojo::Base 'DCS::API::Base::Controller';

use Readonly;
use DCS::NameConversion qw(convert_hash_keys snake_to_camel);
use DCS::Constants qw(:symbols);

use experimental qw(signatures);

Readonly::Scalar my $DOUBLE_COLON => qq{$COLON$COLON};
Readonly::Scalar my $LAST_ITEM    => -1;

sub render_model ($self, $model) {
  return [map {$self->render_model($_)} @$model] if (ref($model) eq 'ARRAY');
  return {map {$_ => $self->render_model($model->{$_})} keys(%$model)} if (ref($model) eq 'HASH');

  my $type = (split("$COLON$COLON", ref($model)))[-1];
  my $r_func = lc("render_model_$type");
  if ($self->can($r_func)) {
    return $self->$r_func($model);
  }
  return {convert_hash_keys($model->get_columns, \&snake_to_camel)};
}

sub render_paginated_list ($self, $rs) {
  return $self->SUPER::render_paginated_list($rs, sub {$self->render_model(@_)});
}

sub render_boolean ($self, $value) {
  return $value eq 'Y';
}

sub render_datetime ($self, $dt) {
  return $dt->iso8601;
}

sub render_date ($self, $dt) {
  return $dt->ymd;
}

sub render_time ($self, $dt) {
  return $dt->strftime('%T');
}

sub model_name($self) {
  return (split($DOUBLE_COLON, ref($self)))[$LAST_ITEM];
}

sub resultset($self) {
  return $self->model($self->model_name);
}

1;
