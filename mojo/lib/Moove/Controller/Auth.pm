package Moove::Controller::Auth;
use Mojo::Base 'DCS::API::Base::Auth';

use Role::Tiny::With;
with 'Moove::Controller::Role::ModelEncoding::AuthUser';
with 'Moove::Controller::Role::ModelEncoding::Default';

# use DateTime;

use experimental qw(signatures);

1;
