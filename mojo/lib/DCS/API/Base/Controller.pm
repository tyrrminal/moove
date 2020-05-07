package DCS::API::Base::Controller;

# ABSTRACT: Base class for API controllers

use Mojo::Base 'Mojolicious::Controller';

use List::Util qw(min);
use Readonly;

use HTTP::Status qw(:constants);
use DCS::Constants qw(:symbols);
Readonly::Scalar my $DEFAULT_PAGELEN => 10;
Readonly::Scalar my $DOUBLE_COLON    => $COLON x 2;

use experimental qw(signatures);

sub model_find {
  my $self  = shift;    # from beginning (required)
  my $id    = pop;      # from end (re)
  my $model = shift;    # from middle (conditional)
  return unless (defined($id));
  $model = (split($DOUBLE_COLON, ref($self)))[-1] unless ($model);
  my $obj = $self->model($model)->find($id);
  return $obj;
}

sub default_pagelen($self) {
  return $DEFAULT_PAGELEN;
}

sub max_pagelen($self) {
  return undef;
}

sub paginate ($self, $rs) {
  my $total   = $rs->count;
  my $page    = $self->validation->param('page') // 1;
  my $pagelen = min(grep {defined} (($self->validation->param('pagelen') // $self->default_pagelen), $self->max_pagelen));
  my $start   = ($page - 1) * $pagelen;
  $rs = $rs->slice($start, $start + $pagelen - 1);

  my ($url, %next, %prev) = $self->req->url->to_abs;
  if ($total > $page * $pagelen) {
    my $next = $url->clone;
    $next->query({page => $page + 1});
    %next = (next => $next->to_string);
  }
  if ($page > 1) {
    my $prev = $url->clone;
    $prev->query({page => $page - 1});
    %prev = (previous => $prev->to_string);
  }

  return (
    {
      count   => $rs->count,
      total   => $total,
      page    => $page,
      pagelen => $pagelen,
      %next,
      %prev
    },
    $rs
  );
}

sub render_paginated_list ($self, $rs, $item_renderer) {
  my $meta;
  ($meta, $rs) = $self->paginate($rs);

  return $self->render(
    openapi => {
      meta     => $meta,
      elements => [map {$item_renderer->($_)} $rs->all],
    }
  );
}

sub render_error ($self, $code, @messages) {
  return $self->render(
    status  => $code,
    openapi => {
      errors => [map {{message => $_}} @messages]
    }
  );
}

sub render_not_found ($self, $model) {
  return $self->render_error(HTTP_NOT_FOUND, "$model not found");
}

sub render_not_authorized ($self, $message = undef) {
  return $self->render_error(HTTP_FORBIDDEN, join(': ', grep {defined} ("Authorization denied", $message)));
}

sub render_no_content($self) {
  return $self->render(status => HTTP_NO_CONTENT, openapi => $EMPTY);
}

sub render_cached($self) {
  return $self->render(status => HTTP_NOT_MODIFIED, openapi => $EMPTY);
}

1;
