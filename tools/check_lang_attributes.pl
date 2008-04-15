#!/usr/bin/env perl
#
# gimp-help-2 -- Check 'lang' attributes
# Copyright (C) 2007, 2008 The GIMP Documentation Team.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

=head1 NAME

check_lang_attributes.pl - Find malformed 'lang' attributes in XML files 


=head1 SYNOPSIS

B<cd> I<gimp-help-2-root-dir>	# where src/ and tools/ are

[B<perl>] B<tools/check_lang_attributes.pl> I<file> ...

B<find> src/ -name '.svn' -prune -o -name '*.xml' -print |
    B<xargs> [B<perl>] B<tools/check_lang_attributes.pl>
	# deprecated

[B<perl>] B<tools/check_lang_attributes.pl> [B<--path>] I<path/to/src>
	# new


=head1 DESCRIPTION

This script reads all XML files and reports every line, which contains
a lang attribute different from the format

        lang="xx;yy_YY;zz".

Note that it will also print lang attributes with leading or trailing
semicolons, although I<xsltproc> will accept them.
Use B<--relax> to prevent the output of these lines.

=cut

# Ok, actually this more an exercise in using Perl's embedded pod docs
# than anything else - but don't tell anybody...


use warnings;
use strict;
use English;
use Getopt::Long;
use File::Find;

# Regex for matching a locale:
#     - an ISO 639 language code
#     - an ISO 3166 country code (optional)
my $Locale = qr/ [a-z]{2} (?: _ [A-Z]{2} )? /x;
# Regex for matching a lang attribute:
my $Lang_attribute = qr{ lang=["']
                         $Locale
                         (?: ; $Locale)*
                         ["'] 
                     }x;
# Relaxed version of the above regex:
my $Lang_attribute_relaxed = qr{ lang=["']
                                 ;*
                                 $Locale
                                 (?: ;+ $Locale)*
                                 ;*
                                 ["']
                             }x;

=head1 OPTIONS

=over 4

=item B<-v> | B<--verbose>

Print the number of XML source files to be scanned (only if used in
conjunction with B<--path>). 

=item B<-p> | B<--path> I<PATH>

Specify the path to XML source files.

For convenience, if neither the B<--path> option nor any file names have
been specified at the command line, the script will try "src".

=item B<-r> | B<--relax>

Ignore e.g. leading and trailing semicolons. This is extremely useful
if you like lang attributes like this:

=over 8

lang=";en;;de;fr;;;;;it;no;;"

=back

=cut 


#-------------------------------------------------------
#       Command line options and defaults
#-------------------------------------------------------

# Defaults
my $Verbose;	# print some messages?
my $Path;	# Search path (use instead of file list)

# Read command line options:
GetOptions(
    'verbose' => \$Verbose,
    'path=s'  => \$Path,
    'relax'   => sub { $Lang_attribute = $Lang_attribute_relaxed },
    'help'    => sub { usage() },
) or exit 64;	# 64 = "command line usage error"

# There's more than one way to specify the search path:
if (!$Path) {
    if (!@ARGV) {
        if (-d "src") {
            $Path = "src";
        } else {
            usage(64, "No path or files specified");
        }
    } elsif (scalar(@ARGV) == 1) {
        # Search path as command line argument:
        $Path = shift @ARGV
    }
}


#-------------------------------------------------------
#       Constructing the file list
#-------------------------------------------------------

if ($Path) {
    usage(66, "No such directory: $Path") unless -d $Path;

    if (@ARGV) {
        warn "Warning: additional command line arguments " .
             "will be overwritten!\n";
        @ARGV = ();
    }

    find(sub { /^\.svn/ and ($File::Find::prune = 1)
                                                 or
               /\.xml$/ and push(@ARGV, $File::Find::name)
             },
             $Path);

    die "Error: No XML files in $Path\n" unless @ARGV;
    print STDERR "Checking ", scalar @ARGV, " XML files ...\n" if $Verbose;
}


#-------------------------------------------------------
#       Main loop: grepping files
#-------------------------------------------------------

while (<>) {
    next unless /lang=['"]/;
    next if     /$Lang_attribute/o;
    s/^\s+//; s/\s+$//;
    print "$ARGV: $NR: $_\n";
} continue {
    # reset line number:
    close ARGV if eof;
}

exit 0;


#---------------------------------------------------------------
sub usage {
#---------------------------------------------------------------
    my $exit_code = shift || 0;
    my $msg       = shift || "";

    select(STDERR) if $exit_code;
    if ($msg) {
        print "Error: ", $msg, "\n"
    } else {
        print <<EOF
check_lang_attributes.pl - Copyright (C) 2007, 2008 The GIMP Documentation Team.
Find malformed 'lang' attributes in docbook xml files.
EOF
    }
    if ($exit_code == 0 || $exit_code == 64) {
        print <<EOF;

Usage:
    check_lang_attributes.pl [options]
    check_lang_attributes.pl [options-not-path] file [file ...]

Options:
    -h | --help         this help
    -v | --verbose      print more info while running
    -p | --path <PATH>  path to XML source files
    -r | --relax        ignore superfluous semicolons

Try 'perldoc $0' for more help.
EOF
    }
    exit $exit_code;
}

__END__

=head1 BUGS

The script has not tested under Microsoft Windows, Mac OS X.

=head1 AUTHOR

Ulf-D. Ehlert

=head1 COPYRIGHT

(C) 2007, 2008 The GIMP Docomentation Team.

License: GPL

