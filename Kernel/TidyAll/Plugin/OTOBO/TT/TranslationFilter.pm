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

package TidyAll::Plugin::OTOBO::TT::TranslationFilter;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        # Process lines that deal with translation output in function form.
        while ( $Line =~ m{ \[% \s* \bTranslate\(([^()]*|\([^()]*\))*\)? (?<Filter>.*?) %\] }gsxm ) {

            # Check if output is not filtered.
            if ( $+{Filter} !~ m{ \s* (?:FILTER|\|) \s* (?:html|JSON) }sxm ) {
                $ErrorMessage
                    .= "ERROR: Found unfiltered translation string in line( $Counter ): $Line\n";
            }
        }

        # Process lines that deal with translation output in filter form.
        while ( $Line =~ m{ (?:FILTER|\|) \s* \bTranslate (?<Filter>.*?) %\] }gsxm ) {

            # Check if output is not filtered.
            if ( $+{Filter} !~ m{ \s* (?:FILTER|\|) \s* (?:html|JSON) }sxm ) {
                $ErrorMessage
                    .= "ERROR: Found unfiltered translation string in line( $Counter ): $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(
            "${ErrorMessage}Please make sure to process translated strings with html or JSON filter.\n"
        );
    }

    return;
}

1;
