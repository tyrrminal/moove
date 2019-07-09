use utf8;
package CardioTracker::Model;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-10-15 20:45:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/52uPKaUORjyvFwyae56TA
use v5.20;
use feature qw(signatures);
no warnings qw(experimental::signatures);

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
