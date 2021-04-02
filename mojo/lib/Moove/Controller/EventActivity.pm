package Moove::Controller::EventActivity;
use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::API::Role::Rest::Create', 'DCS::API::Role::Rest::Update', 'DCS::API::Role::Rest::Delete';

use experimental qw(signatures postderef);


1;
