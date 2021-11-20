package WWW::KeePassHttp::Entry;
use 5.012;  # //, strict, s//r
use warnings;

use MIME::Base64;
use Crypt::Mode::CBC;
use HTTP::Tiny;
use JSON;   # will use JSON::XS when available
use Time::HiRes qw/gettimeofday sleep/;
use MIME::Base64;
use Carp;

our $VERSION = '0.010';  # rrr.mmmsss : rrr is major revision; mmm is minor revision; sss is sub-revision (new feature path or bugfix); optionally use _sss instead, for alpha sub-releases

my $dumpfn;
BEGIN {
    $dumpfn = sub { JSON->new->utf8->pretty->encode($_[0]) } # hidden from podcheckers and external namespace
}

=pod

=head1 NAME

WWW::KeePassHttp::Entry - Object-oriented access to an Entry retrived using WWW::KeePassHttp

=head1 SYNOPSIS

    use WWW::KeePassHttp;

    my $kph = WWW::KeePassHttp->new(Key => $key);
    $kph->associate() unless $kph->test_associate();
    my @entries = @${ $kph->get_logins($search_string) };
    print $entry[0]->url;
    print $entry[0]->login;
    print $entry[0]->password;

=head1 DESCRIPTION

Object-oriented access to an Entry retrived using L<WWW::KeePassHttp>.


=head1 DETAILS

=over

=item new

    my $entry = WWW::KeePassHttp::Entry->new( Url => 'https://github.com', Login => 'username', Password => 'password');

Creates a new Entry object.

L<WWW::KeePassHttp> will do this for you when you grab entries.
Or you can create a new Entry object when you want to L<set_login|WWW::KeePassHttp/set_login>

Url, Login, and Password are all required to be defined.  If you want those fields "empty",
just use an emtpy string C<''> as the value.

=cut

sub new
{
    my ($class, %opts) = @_;
    my $self = bless {}, $class;

    $self->{Url} = $opts{Url}; die "missing Url" unless defined $self->{Url};
    $self->{Login} = $opts{Login}; die "missing Login" unless defined $self->{Login};
    $self->{Password} = $opts{Password}; die "missing Password" unless defined $self->{Password};

    return $self;
}

=item url

    print $entry->url();
    $entry->url('https://new.url/');    # set new value

The getter/setter for the Url of the Entry.

=cut

sub url
{
    my ($self, $val) = @_;
    $self->{Url} = $val if defined $val;
    return $self->{Url};
}

=item login

    print $entry->login();
    $entry->login('https://new.url/');    # set new value

The getter/setter for the Login of the Entry.

=cut

sub login
{
    my ($self, $val) = @_;
    $self->{Login} = $val if defined $val;
    return $self->{Login};
}

=item password

    print $entry->password();
    $entry->password('https://new.url/');    # set new value

The getter/setter for the Password of the Entry.

=cut

sub password
{
    my ($self, $val) = @_;
    $self->{Password} = $val if defined $val;
    return $self->{Password};
}

=back

=for comment END OF DETAILS

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests
thru the repository's interface at L<https://github.com/pryrt/WWW-KeePassHttp/issues>.

=begin html

<a href="https://metacpan.org/pod/WWW::KeePassHttp"><img src="https://img.shields.io/cpan/v/WWW-KeePassHttp.svg?colorB=00CC00" alt="" title="metacpan"></a>
<a href="https://matrix.cpantesters.org/?dist=WWW-KeePassHttp"><img src="https://cpants.cpanauthors.org/dist/WWW-KeePassHttp.png" alt="" title="cpan testers"></a>
<a href="https://github.com/pryrt/WWW-KeePassHttp/releases"><img src="https://img.shields.io/github/release/pryrt/WWW-KeePassHttp.svg" alt="" title="github release"></a>
<a href="https://github.com/pryrt/WWW-KeePassHttp/issues"><img src="https://img.shields.io/github/issues/pryrt/WWW-KeePassHttp.svg" alt="" title="issues"></a>
<a href="https://coveralls.io/github/pryrt/WWW-KeePassHttp?branch=main"><img src="https://coveralls.io/repos/github/pryrt/WWW-KeePassHttp/badge.svg?branch=main" alt="Coverage Status" /></a>
<a href="https://github.com/pryrt/WWW-KeePassHttp/actions/"><img src="https://github.com/pryrt/WWW-KeePassHttp/actions/workflows/perl-ci.yml/badge.svg" alt="github perl-ci"></a>

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
