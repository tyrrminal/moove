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
use experimental qw(signatures postderef);

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-02 11:05:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a26XEOOFhrxY7Bm8m1+J5A

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
