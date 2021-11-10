# This will test through a standard workflow / use-case to read an entry from KeePass
#
use 5.012; # strict, //
use warnings;
use Test::More;
use Test::Exception;

use WWW::KeePassHttp;

# constructor: Key error checking
throws_ok { WWW::KeePassHttp->new() } qr/^\Q256-bit AES key is required/, 'error: missing key';
throws_ok { WWW::KeePassHttp->new(Key => undef) } qr/^\Q256-bit AES key is required/, 'error: undefined key';
throws_ok { WWW::KeePassHttp->new(Key => 0) } qr/^\QKey not recognized as 256-bit AES/, 'error: unrecognizeable key';
throws_ok { WWW::KeePassHttp->new(Key => 'CRyXRbH9vBkdPrkdm52S3bTG2rGtnYuyJttk/mlJ15g=') } qr/^\Q256-bit AES key must be in octets, not in base64/, 'error: base64 key';
throws_ok { WWW::KeePassHttp->new(Key => "CRyXRbH9vBkdPrkdm52S3bTG2rGtnYuyJttk/mlJ15g=\n") } qr/^\Q256-bit AES key must be in octets, not in base64/, 'error: base64 key with newline';
throws_ok { WWW::KeePassHttp->new(Key => "091c9745b1fdbc191d3eb91d9b9d92ddb4c6dab1ad9d8bb226db64fe6949d798") } qr/^\Q256-bit AES key must be in octets, not hex nibbles/, 'error: hex nibbles';
throws_ok { WWW::KeePassHttp->new(Key => "0x091c9745b1fdbc191d3eb91d9b9d92ddb4c6dab1ad9d8bb226db64fe6949d798") } qr/^\Q256-bit AES key must be in octets, not hex nibbles/, 'error: hex nibbles with 0x';

done_testing();
