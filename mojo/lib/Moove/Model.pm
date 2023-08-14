#<<<
use utf8;
package Moove::Model;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vMLfTgq56++45cD+62QzGg

# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub new ($class, $dsn, $user, $pass) {
  return __PACKAGE__->connect(
    $dsn, $user, $pass, {
      mysql_auto_reconnect => 1,
      mysql_enable_utf8    => 1
    }
    );
}

1;
