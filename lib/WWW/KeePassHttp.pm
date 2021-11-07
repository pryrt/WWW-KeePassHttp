package KeePassHttp;
use 5.012;  # //, strict, s//r
use warnings;
use Exporter 5.57 'import';

our $VERSION = '0.000001';  # rrr.mmmsss : rrr is major revision; mmm is minor revision; sss is sub-revision (new feature path or bugfix); optionally use _sss instead, for alpha sub-releases


=pod

=head1 NAME

WWW::KeePassHttp - Interface with KeePass PasswordSafe through the KeePassHttp plugin

=head1 SYNOPSIS

    use WWW::KeePassHttp;

=head1 DESCRIPTION

Interface with KeePass PasswordSafe through the KeePassHttp plugin.  Allows reading entries based on URL or TITLE.  Maybe will allow creating a new entry as well.

=head2 REQUIREMENTS

You need to have KeePass (or compatible) on your system, with the KeePassHttp plugin installed.



=cut

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


1;
