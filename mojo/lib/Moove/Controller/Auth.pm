package Moove::Controller::Auth;
use v5.38;

use Mojo::Base 'DCS::Base::API::Auth::Controller';

use Role::Tiny::With;
with 'Moove::Controller::Role::ModelEncoding::AuthUser';
with 'Moove::Controller::Role::ModelEncoding::Default';

1;
