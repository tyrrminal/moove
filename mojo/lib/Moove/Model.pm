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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:90Rmrg/Dly69P+pu5+DiIA

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
