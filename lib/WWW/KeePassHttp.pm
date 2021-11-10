package WWW::KeePassHttp;
use 5.012;  # //, strict, s//r
use warnings;

use MIME::Base64;
use Crypt::Mode::CBC;
use HTTP::Tiny;
use JSON;   # will use JSON::XS when available
use Time::HiRes qw/gettimeofday sleep/;
use MIME::Base64;
use Carp;

our $VERSION = '0.000001';  # rrr.mmmsss : rrr is major revision; mmm is minor revision; sss is sub-revision (new feature path or bugfix); optionally use _sss instead, for alpha sub-releases

my $dumpfn;
BEGIN {
    eval {
        require Data::Dump;
        $dumpfn = \&Data::Dump::dump;
        1;
    } or eval {
        require Data::Dumper;
        $dumpfn = \&Data::Dumper::Dumper;
        1;
    }
}


=pod

=head1 NAME

WWW::KeePassHttp - Interface with KeePass PasswordSafe through the KeePassHttp plugin

=head1 SYNOPSIS

    use WWW::KeePassHttp;

=head1 DESCRIPTION

Interface with KeePass PasswordSafe through the KeePassHttp plugin.  Allows reading entries based on URL or TITLE.  Maybe will allow creating a new entry as well.

=head2 REQUIREMENTS

You need to have KeePass (or compatible) on your system, with the KeePassHttp plugin installed.

=head1 INTERFACE

=head2 CONSTRUCTOR AND CONFIGURATION

=over

=item new

    my $kph = WWW::KeePassHttp->new( Key => $key, %options);

Creates a new KeePassHttp connection, and sets up the AES encryption.

The C<Key =E<gt> $key> is required; pass in a string of 32 octets that
represent a 256-bit key value.  If you have your key as 64 hex nibbles,
then use C<$key = pack 'H*', $hexnibbles;> to convert it to the value.
If you have your key as a Base64 string, use
C<$key = decode_base64($base64string);> to convert it to the value.

The remaining options share the same name and purposes with the
configuration methods that follow.

=cut

sub new
{
    my ($class, %opts) = @_;
    my $self = bless {}, $class;

    # user agent and URL
    $opts{keep_alive} //= 1;                        # default to keep_alive
    $self->{ua} = HTTP::Tiny->new(keep_alive => $opts{keep_alive} );

    $self->{request_base} = $opts{request_url} // 'http://localhost';   # default to localhost
    $self->{request_port} = $opts{request_port} // 19455;               # default to 19455
    $self->{request_url} = $self->{request_base} . ':' . $self->{request_port};

    # encryption object
    $self->{cbc} = Crypt::Mode::CBC->new('AES');
    $self->{key} = $opts{Key} // croak "256-bit AES key is required";
    for($self->{key}) {
        last if length($_) == 32;   # a 32-octet string is assumed to be a valid key
        chomp;
        croak "256-bit AES key must be in octets, not hex nibbles"
            if /^(0x)?[[:xdigit:]]{64}$/;
        croak "256-bit AES key must be in octets, not in base64"
            if length($_) == 44;
        croak "Key not recognized as 256-bit AES";
    }

    return $self;
}

=item host

    %options = ( ...,  host => 'localhost', ... );
        or
    $kph->host('127.0.0.1');

Changes the host: the KeePassHttp plugin defaults to C<localhost>, but can be configured differently, so you will need to make your object match your plugin settings.

=cut

sub host
{
    1;
}

=item port

    %options = ( ...,  port => 19455, ... );
        or
    $kph->port(19455);

Changes the port: the KeePassHttp plugin defaults to port 19455, but can be configured differently, so you will need to make your object match your plugin settings.

=cut

sub port
{
    1;
}

=item ...

=back

=for comment END OF CONSTRUCTOR AND CONFIGURATION

=head2 USER INTERFACE

These methods implement the L<KeePassHttp plugin's commmunication protocol|https://github.com/pfn/keepasshttp/#a-little-deeper-into-protocol>, with one method for each RequestType.

=over

=item test_associate

    $kph->associate unless $kph->test_associate();

=cut

sub test_associate
{
    my ($self, %args) = @_;
    my $content = $self->request('test-associate', %args);
    return $content->{Success};
}

=item associate

    $kph->associate unless $kph->test_associate();

=cut

sub associate {}

=item get_logins

=cut

sub get_logins {}

=item get_logins_count

=cut

sub get_logins_count {}

=item set_login

=cut

sub set_login {}

=item request

    my $results = $kph->request( $type, %options );

This is the generic method for making a request of the
KeePassHttp plugin. In general, other methods should handle
most requests.  However, maybe a new method has been exposed
in the plugin but not yet implemented here, so you can use
this method for handling that.

The C<$type> indicates the RequestType, which include
C<test-associate>, C<associate>, C<get-logins>,
C<get-logins-count>, and C<set-login>.

This method automatically fills out the RequestType, TriggerUnlock, Id, Nonce, and Verifier parameters.  If your RequestType requires
any other parameters, add them to the C<%options>.

It then encodes the request into the JSON payload, and
sends that request to the KeePassHttp plugin, and gets the response,
decoding the JSON content back into a Perl hashref.  It verifies that
the response's Nonce and Verifier parameters are appropriate for the
communication channel, to make sure communications from the plugin
are properly encrypted.

Returns the hashref decoded from the JSON

=cut

sub request {
    my ($self, $type, %params) = @_;
    my ($iv, $nonce) = generate_nonce();

    #print STDERR "request($type):\n";

    # these are required in every request
    my %request = (
        RequestType => $type,
        TriggerUnlock => JSON::false,
        Id => 'comets.keepalive',
        Nonce => $nonce,
        Verifier => encode_base64($self->{cbc}->encrypt($nonce, $self->{key}, $iv), ''),
    );

    # don't want to encrypt the key during an association request
    $request{Key} = delete $params{Key} if( exists $params{Key} );

    # encrypt all remaining parameter values
    while(my ($k,$v) = each %params) {
        $request{$k} = encode_base64($self->{cbc}->encrypt($v, $self->{key}, $iv), '');
    }
    #dd { my_request => \%request };

    # send the request
    my $response = $self->{ua}->get($self->{request_url}, {content=> encode_json \%request});

    # error checking
    die $dumpfn->( { request_error => $response } ) unless $response->{success};
    die $dumpfn->( { no_json => $response } ) unless exists $response->{content};

    # get the JSON
    my $content = decode_json $response->{content};
    #d { their_content => $content };

    # verification before returning the content -- if their verifier doesn't match their nonce,
    #   then we don't have secure communication
    if($type ne 'test-associate' or exists $content->{Verifier}) { # don't need to check on the first test-associate

        die $dumpfn->(  { missing_verifier => $content } ) unless exists $content->{Nonce} and exists $content->{Verifier};
        my $their_iv = decode_base64($content->{Nonce});
        my $decode_their_verifier = $self->{cbc}->decrypt( decode_base64($content->{Verifier}), $self->{key}, $their_iv );
        if( $decode_their_verifier ne $content->{Nonce} ) {
            die $dumpfn->( { "Decoded Verifier $decode_their_verifier" => $content } );
        }
    }

    # If it made it to here, it's safe to return the content
    return $content;
}

=back

=for comment END OF USER INTERFACE

=head2 HELPER METHODS

In general, most users won't need these.  But maybe I<you> will.

=over

=item generate_nonce

    my ($iv, $base64) = $kph->generate_nonce();

This is used by the L</request> method to generate the IV nonce
for communication.  I don't think you need to use it yourself, but
it's available to you, if you find a need for it.

The C<$iv> is the string of octets (the actual 128 IV nonce value).

The C<$base64> is the base64 representation of the C<$iv>.

=cut

sub generate_nonce
{
    # generate 10 bytes of random numbers, 2 bytes of microsecond time, and 4 bytes of seconds
    #   this gives randomness from two sources (rand and usecond),
    #   plus a deterministic counter that won't repeat for 2^31 seconds (almost 70 years)
    #   so as long as you aren't using the same key for 70 years, the nonce should be unique
    my $hex = '';
    $hex .= sprintf '%02X', rand(256) for 1..10;
    my ($s,$us) = gettimeofday();
    $hex .= sprintf '%04X%08X', $us&0xFFFF, $s&0xFFFFFFFF;
    my $iv = pack 'H*', $hex;
    my $nonce = encode_base64($iv, '');
    return wantarray ? ($iv, $nonce) : $iv;
}

=back

=for comment END OF HELPER METHODS


=head1 SEE ALSO

=over

=item * L<KeePass Plugins list|https://keepass.info/plugins.html>

=item * L<KeePassHttp Plugin home|https://github.com/pfn/keepasshttp/>

=item * L<WWW::KeePassRest> = A similar interface which uses the KeePassRest plugin to interface with KeePass

=back

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests
thru the repository's interface at L<https://github.com/pryrt/WWW-KeePassHttp/issues>.

=begin html

<a href="https://metacpan.org/pod/WWW::KeePassHttp"><img src="https://img.shields.io/cpan/v/WWW-KeePassHttp.svg?colorB=00CC00" alt="" title="metacpan"></a>
<a href="http://matrix.cpantesters.org/?dist=WWW-KeePassHttp"><img src="http://cpants.cpanauthors.org/dist/WWW-KeePassHttp.png" alt="" title="cpan testers"></a>
<a href="https://github.com/pryrt/WWW-KeePassHttp/releases"><img src="https://img.shields.io/github/release/pryrt/WWW-KeePassHttp.svg" alt="" title="github release"></a>
<a href="https://github.com/pryrt/WWW-KeePassHttp/issues"><img src="https://img.shields.io/github/issues/pryrt/WWW-KeePassHttp.svg" alt="" title="issues"></a>
<a href="https://ci.appveyor.com/project/pryrt/WWW-KeePassHttp"><img src="https://ci.appveyor.com/api/projects/status/6gv0lnwj1t6yaykp/branch/master?svg=true" alt="" title="test coverage"></a>

=end html

=head1 COPYRIGHT

Copyright (C) 2021 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
