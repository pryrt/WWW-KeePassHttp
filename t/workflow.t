# This will test through a standard workflow / use-case to read an entry from KeePass
#
use 5.012; # strict, //
use warnings;
use Test::More;
use MIME::Base64;

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
local $TODO = 'during debug, initial test-associate may succeed, thus failing these tests';
my ($test1, $assoc1, $test2);
$assoc1 = $kph->associate() unless $test1 = $kph->test_associate();
ok !$test1, 'test1 should return false';
isa_ok $assoc1, 'HASH', 'assoc1';
local $TODO = undef;

$test2 = $kph->test_associate();
ok $test2, 'test2 shuold return true';
# TODO: need to do all the mock counting, etc, to make sure that
#   correct internal calls worked, and that parameters sent to UA->get were correct

# verify that get_logins does the right internal sequence:
my $entries = $kph->get_logins('WWW-KeePassHttp');
diag "get_logins => ", explain $entries;
like $entries->[0]->{Name}, qr/^WWW-KeePassHttp$/, 'correct title (entry name)';
like $entries->[0]->{Login}, qr/^developer$/, 'correct username (login)';
like $entries->[0]->{Password}, qr/^secret$/, 'correct password';
# TODO: implement mock-result callstack verification as well

my $count = $kph->get_logins_count('WWW-KeePassHttp');
is $count, 1, 'get-logins-count';
# TODO: callstack verification


# try to create
diag "--------------------";
ok $kph->set_login(
        Login => 'workflow.t.username',
        Url => 'workflow.t.url',
        Password => 'workflow.t.password',
    ), 'set-login returns a success';

done_testing();
