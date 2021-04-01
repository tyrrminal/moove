package Moove::Controller::Auth;
use Mojo::Base 'DCS::Base::API::Auth::Controller';

use Role::Tiny::With;
with 'Moove::Controller::Role::ModelEncoding::AuthUser';
with 'Moove::Controller::Role::ModelEncoding::Default';

# use DateTime;

use experimental qw(signatures);

1;
