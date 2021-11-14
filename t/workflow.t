# This will test through a standard workflow / use-case to read an entry from KeePass
#
use 5.012; # strict, //
use warnings;
use Test::More;
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

my @series = (
    {
        content  => "{\"RequestType\":\"test-associate\",\"Success\":false,\"Count\":0,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\"}",
        success => 1,
    },
    {
        content  => "{\"RequestType\":\"associate\",\"Success\":true,\"Id\":\"WWW::KeePassHttp\",\"Count\":0,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"iPrW6C0Lzu7pVpod958KJA==\",\"Verifier\":\"rysKFzLXKKUigKxU7aVbtHwMZH2rqXRz2ka9Hi7Rojw=\"}",
        success => 1,
    },
    {
        content  => "{\"RequestType\":\"test-associate\",\"Success\":true,\"Id\":\"WWW::KeePassHttp\",\"Count\":0,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"7HPSAzGWKINfj9+MRLgZJg==\",\"Verifier\":\"dG1ZOgSAA/coB1tc9G5OPqkpuviPyMUizThf/IbEI54=\"}",
        success => 1,
    },
    {
        content  => "{\"RequestType\":\"get-logins\",\"Success\":true,\"Id\":\"WWW::KeePassHttp\",\"Count\":1,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"AqvxYWMArZTbRoZcU+a21Q==\",\"Verifier\":\"rl6RCAhGIvGdNB5J/6Yo5p5+8c3K/6Yg9sK3G2CXysw=\",\"Entries\":[{\"Login\":\"URDpgbTnHWZfMd9mddik3Q==\",\"Password\":\"k0krqs1+W2mc3QBJP01Z5w==\",\"Uuid\":\"BmcYDdjoivBoG3dYozsaqOkJuBeZMQYKeQjnND+Xjfzzr/d/UPD0/QsuDcvj2ZnF\",\"Name\":\"AfeSGKHYGqtslglqqzKo7Q==\"}]}",
        success => 1,
    },
    {
        content  => "{\"RequestType\":\"get-logins-count\",\"Success\":true,\"Id\":\"WWW::KeePassHttp\",\"Count\":1,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"5ExkCS6g7jGQLf/IIc7DGQ==\",\"Verifier\":\"uK0gRC1ERf2+XYL4ji/ERLmrWQZwjPXP4lVRi+NQ7Xw=\"}",
        success => 1,
    },
    {
        content  => "{\"RequestType\":\"set-login\",\"Success\":true,\"Id\":\"WWW::KeePassHttp\",\"Count\":0,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\",\"Nonce\":\"gSJXXhByYIhc6zpnbG8FpA==\",\"Verifier\":\"S5PbXFEtbVwsXcBjYMM1EurG+7XsfcN2NI2R/Clunho=\"}",
        success => 1,
    },
);
$mock->set_series( get => @series );

sub test_next_mocked_get
{
    my ($mock, $testname_prefix, %match_args) = @_;
    my ($name, $arglist) = $mock->next_call();
    #is $name, 'get', $testname_prefix . ": is a get";
    (undef, my $get_url, my $get_options) = @$arglist;

    is $get_url, delete($match_args{URL}), "$testname_prefix: correct UA URL" if exists $match_args{URL};

    ok exists $get_options->{content}, "$testname_prefix: UA content exists";

    my $content = decode_json($get_options->{content})//{};

    is $content->{$_}, $match_args{$_}, "$testname_prefix: correct $_" for sort keys %match_args;

    note "$testname_prefix: ", explain { $get_url => $get_options };
}




use WWW::KeePassHttp;

# NOTE: this key is used for testing (it was the key used in the example at https://github.com/pfn/keepasshttp/)
#   it is NOT the value you should use for your key in the real application
#   In a real application, you must generate a 256-bit cryptographically secure key,
#   using something like Math::Random::Secure or Crypt::Random,
#   or use `openssl enc -aes-256-cbc -k secret -P -md sha256 -pbkdf2 -iter 100000`
#       and convert the 64 hex nibbles to a key using pack 'H*', $sixtyfournibbles
my $key = decode_base64('CRyXRbH9vBkdPrkdm52S3bTG2rGtnYuyJttk/mlJ15g=');

# start by intializing the kph object with your key
my $kph = WWW::KeePassHttp->new(Key => $key);
isa_ok $kph, 'WWW::KeePassHttp', 'created interface';

# verify that the association idiom works correctly:
#   $kph->associate unless $kph->test_associate
#
# To test this, run the idiom once, storing the extra return values
#   => it should test1 false and then run the association
#   the second time, just run the test-association, which should test2 true
my ($test1, $assoc1, $test2);
$assoc1 = $kph->associate() unless $test1 = $kph->test_associate();
ok !$test1, 'test1 should return false';
isa_ok $assoc1, 'HASH', 'assoc1';

$test2 = $kph->test_associate();
ok $test2, 'test2 should return true';
# TODO: need to do all the mock counting, etc, to make sure that
#   correct internal calls worked, and that parameters sent to UA->get were correct
test_next_mocked_get($mock, 'first test-associate call', URL => 'http://localhost:19455', RequestType => 'test-associate');
#test_mocked_get $mock->next_call(), 'http://localhost:19455', "{\"RequestType\":\"test-associate\",\"Success\":false,\"Count\":0,\"Version\":\"1.8.4.2\",\"Hash\":\"91dfdf648925fa42f69f1dbe3b012afcc43aca42\"}";
$mock->clear();

# verify that get_logins does the right internal sequence:
my $entries = $kph->get_logins('WWW-KeePassHttp');
like $entries->[0]->{Name}, qr/^WWW-KeePassHttp$/, 'correct title (entry name)';
like $entries->[0]->{Login}, qr/^developer$/, 'correct username (login)';
like $entries->[0]->{Password}, qr/^secret$/, 'correct password';
# TODO: implement mock-result callstack verification as well

# count the number of entries
my $count = $kph->get_logins_count('WWW-KeePassHttp');
is $count, 1, 'get-logins-count';
# TODO: callstack verification


# try to create
ok $kph->set_login(
        Login => 'workflow.t.username',
        Url => 'workflow.t.url',
        Password => 'workflow.t.password',
    ), 'set-login returns a success';

done_testing();


__END__
