# This will test through a standard workflow / use-case to read an entry from KeePass
#
use 5.012; # strict, //
use warnings;
use Test::More;
use Test::Exception;
use Test::MockObject;
use MIME::Base64;
use JSON;

my $mock;

BEGIN {
    $mock = Test::MockObject->new();
    $mock->fake_module( 'HTTP::Tiny' );
    $mock->fake_new( 'HTTP::Tiny' );
    $mock->set_isa( 'HTTP::Tiny' );
}

# this is the series of ->get() results, required to provoke various error conditions
my @series = (
    {
        content  => "{\"RequestType\":\"get-logins\",\"Success\":true,\"Id\":\"err-mocked.t\",\"Count\":1,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"AqvxYWMArZTbRoZcU+a21Q==\",\"Verifier\":\"rl6RCAhGIvGdNB5J/6Yo5p5+8c3K/6Yg9sK3G2CXysw=\",\"Entries\":[{\"Login\":\"URDpgbTnHWZfMd9mddik3Q==\",\"Password\":\"k0krqs1+W2mc3QBJP01Z5w==\",\"Uuid\":\"BmcYDdjoivBoG3dYozsaqOkJuBeZMQYKeQjnND+Xjfzzr/d/UPD0/QsuDcvj2ZnF\",\"Name\":\"AfeSGKHYGqtslglqqzKo7Q==\"}]}",
        success => 1,
    },
    {
        content  => "{\"RequestType\":\"get-logins\",\"Success\":true,\"Count\":1,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"AqvxYWMArZTbRoZcU+a21Q==\",\"Verifier\":\"rl6RCAhGIvGdNB5J/6Yo5p5+8c3K/6Yg9sK3G2CXysw=\",\"Entries\":[{\"Login\":\"URDpgbTnHWZfMd9mddik3Q==\",\"Password\":\"k0krqs1+W2mc3QBJP01Z5w==\",\"Uuid\":\"BmcYDdjoivBoG3dYozsaqOkJuBeZMQYKeQjnND+Xjfzzr/d/UPD0/QsuDcvj2ZnF\",\"Name\":\"AfeSGKHYGqtslglqqzKo7Q==\"}]}",
        success => 1,
    },
    #undef,
    # { # valid associate response
    #     content  => "{\"RequestType\":\"get-logins\",\"Success\":true,\"Id\":\"WWW::KeePassHttp\",\"Count\":1,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"AqvxYWMArZTbRoZcU+a21Q==\",\"Verifier\":\"rl6RCAhGIvGdNB5J/6Yo5p5+8c3K/6Yg9sK3G2CXysw=\",\"Entries\":[{\"Login\":\"URDpgbTnHWZfMd9mddik3Q==\",\"Password\":\"k0krqs1+W2mc3QBJP01Z5w==\",\"Uuid\":\"BmcYDdjoivBoG3dYozsaqOkJuBeZMQYKeQjnND+Xjfzzr/d/UPD0/QsuDcvj2ZnF\",\"Name\":\"AfeSGKHYGqtslglqqzKo7Q==\"}]}",
    #     success => 1,
    # },
);
$mock->set_series( get => @series );

use WWW::KeePassHttp;

# need an object for some tests
my $key = decode_base64(my $key64='CRyXRbH9vBkdPrkdm52S3bTG2rGtnYuyJttk/mlJ15g=');
my $kph = WWW::KeePassHttp->new(Key => $key);
throws_ok { $kph->associate(); } qr/Wrong ID:/, 'associate error: Wrong App ID';
throws_ok { $kph->associate(); } qr/Wrong ID:/, 'associate error: missing (ie, undefined) ID';
local $TODO = "haven't figured out how to trigger \$content//'undef' in the error conditions";
throws_ok { $kph->associate(); } qr/Wrong ID:/, 'associate error: missing (ie, undefined) content';

done_testing();
