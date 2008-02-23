#!/usr/bin/env perl
#
# check_keywords_property.pl
#
# This script checks for every xml file if the 'svn:keywords' property
# is set correctly.
#
# It calls "svn --recursive propget 'svn:keywords' src" and writes
# file names to stdout if no property or non-default property set,
# and optionally its non-default property (in parantheses).
#
# Usage:
#     cd <top_srcdir>  # where src/ and tools/ are
#     tools/check_keywords_property.pl [-v]
#                         or
#     perl tools/check_keywords_property.pl [-v]
#

use warnings;
use strict;
use Getopt::Long;

eval { require 5.008; };	# needed for the special "open()" list form
my $HAVE_NEW_OPEN = $@ ? 0 : 1;


# --------------------------------------------------------------
#  Variables and "constants"
# --------------------------------------------------------------

my $Default_property='Author Date Id Revision';
my %property;	# (filename, property) pairs
my $verbose = 0;


# --------------------------------------------------------------
#  Handle command line options
# --------------------------------------------------------------

GetOptions(
    'v|verbose!' => \$verbose,
    'h|help'     => sub { usage(); exit 0; },
) or die "Try $0 --help.\n";

sub usage {
    print <<EOF;
Usage:
    From the gimp-help-2 root (where src/ and tools/ are):
        $0 [options]
    or
        perl $0 [options]
Options:
    -h | --help     -  print this text
    -v | --verbose  -  print some informative messages to STDERR while running
                       and report non-default properties
EOF
}


# --------------------------------------------------------------
#  Check working directory
# --------------------------------------------------------------

unless (-d 'src' && -d '.svn' && system('svn info >/dev/null 2>&1') == 0) {
    die "This script must be called from the gimp-help-2 root directory.\n";
}


# --------------------------------------------------------------
#  Print 'svn:keywords' properties
# --------------------------------------------------------------

print STDERR "Searching for files with missing/wrong properties...\n"
    if $verbose;

if ($HAVE_NEW_OPEN) {
    open(PROPLIST, '-|', 'svn', '--recursive', 'propget', 'svn:keywords', 'src')
        or die "Cannot open pipe to SVN: $!\n";
} else {
    open(PROPLIST, "svn --recursive propget svn:keywords src |")
        or die "Cannot open pipe to SVN: $!\n";
}


# --------------------------------------------------------------
#  Read list of file names and 'svn:keywords' properties
#  and add files to the %property hash if they don't have the
#  default property
# --------------------------------------------------------------

my $nfiles = 0;

while (<PROPLIST>) {
    # Format of svn output:
    #     <file-name> <space> '-' <space> <svn-properties>
    #     ...
    chomp;
    if (/^(\S+) - *(\S.*)?$/) {
        ++$nfiles;
        if (defined $2) {
            $property{$1} = $2 if ($2 ne $Default_property);
        } else {
            $property{$1} = "";
        }
    }
}
close(PROPLIST) or die "Cannot close pipe from SVN: $!\n";


# --------------------------------------------------------------
#  Read the %property hash:
#      key:   file name
#      value: svn:keywords property:
#              ""  if no property
#          string  if non-default property
# --------------------------------------------------------------

print STDERR "Found ", scalar keys(%property), " of $nfiles files",
             (scalar keys(%property) > 0 ? ":" : "."), "\n"
    if $verbose;

# Print sorted list of matches:
foreach (sort keys(%property)) {
    print $_, ($property{$_} ? " ($property{$_})" : ""), "\n";
}


# Exit code:
#       0  if no file without default property found,
#     128  if one or more files without default property found,
#       *  on error.
exit((scalar keys(%property)) ? 128 : 0);


