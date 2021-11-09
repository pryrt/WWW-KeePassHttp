# This will test through a standard workflow / use-case to read an entry from KeePass
#
use 5.012; # strict, //
use warnings;
use Test::More tests=>2;

use_ok('WWW::KeePassHttp');

diag my $ossl = ($^X =~ s/perl.bin.perl.exe//ir =~ s{\\}{/}gir) . 'c/bin/openssl.exe';
ok -f $ossl, $ossl;

done_testing();
