#!/usr/bin/env perl
#
# check_lang_attributes.pl
#
# This script reads all files provided as command-line arguments
# and reports every line containing a lang attribute, which does
# not (exactly) match the correct format (lang="xx;yy_YY;zz").
# (So it will print e.g. lang attributes with leading or trailing
# semicolons, although docbook-xsl will accept them.) 
#
# Usage:
#     cd <top_srcdir>  # where src/ and tools/ are
#     find src/ -path '*/.svn' -prune -o -name '*.xml' -print |
#     xargs tools/check_lang_attributes.pl
#

use warnings;
use strict;
use English;

# A regex for matching a locale:
my $Locale         = qr/ [a-z]{2} ( _ [A-Z]{2} )? /x;
# A regex for matching a lang attribute:
my $Lang_attribute = qr{ lang=["'] $Locale (; $Locale)* ["'] }x;
# A relaxed version of the above regex (not used, not tested):
#my $Lang_attribute = qr{ lang=["'] ;* $Locale (;+ $Locale)* ;* ["'] }x;

while (<>) {
    next unless /lang=['"]/;
    next if     /$Lang_attribute/o;
    s/^\s+//; s/\s+$//;
    print "$ARGV: $NR: $_\n";
} continue {
    # reset line number:
    close ARGV if eof;
}

exit 0
