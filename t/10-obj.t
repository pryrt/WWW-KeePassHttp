use 5.012; # strict, //
use warnings;
use Test::More tests=>3;

use WWW::KeePassHttp;

my $obj = WWW::KeePassHttp->new();
isa_ok($obj, 'WWW::KeePassHttp', 'main object');
isa_ok($obj->{ua}, 'HTTP::Tiny', 'user agent object');
isa_ok($obj->{cbc}, 'Crypt::Mode::CBC', 'encryption object');

done_testing();
