# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package TidyAll::Plugin::OTOBO::Perl::ScriptFormat;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    # For framework 3.2 or later, rewrite /usr/bin/perl -w to
    # /usr/bin/perl
    # we use 'use warnings;' which works lexical and not global

    $Code =~ s{\A\#!/usr/bin/perl[ ]-w}{\#!/usr/bin/perl}xms;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check for presence of shebang line
    if ( $Code !~ m{\A\#!/usr/bin/perl\s*(?:-w)?}xms ) {
        return $Self->DieWithError(<<"EOF");
Need #!/usr/bin/perl at the start of script files.
EOF
    }

    return;
}

1;