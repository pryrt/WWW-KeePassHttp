# This will test through a standard workflow / use-case to read an entry from KeePass
#
use 5.012; # strict, //
use warnings;
use Test::More tests=>1;

use_ok('WWW::KeePassHttp');
done_testing();
