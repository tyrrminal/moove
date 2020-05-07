package DCS::API::Role::Rest::All;
use Role::Tiny;

use Role::Tiny::With;

with
  'DCS::API::Role::Rest::Create',
  'DCS::API::Role::Rest::Delete',
  'DCS::API::Role::Rest::Get',
  'DCS::API::Role::Rest::List',
  'DCS::API::Role::Rest::Update';

1;
