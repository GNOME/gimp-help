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
use File::Find;

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
#  Find all *.xml files in the "src/" directory hierarchy
#  and add the file names to the %property hash
# --------------------------------------------------------------

print STDERR "Searching for missing/wrong properties:\n" if $verbose;
print STDERR "    searching xml files... "               if $verbose;

find( sub { /^\.svn/ and ($File::Find::prune = 1)
                             or
            /\.xml$/ and ($property{$File::Find::name} = "")
      },
      "src" );

print STDERR scalar keys(%property), "\n"                if $verbose;


# --------------------------------------------------------------
#  Print 'svn:keywords' properties
# --------------------------------------------------------------

if ($HAVE_NEW_OPEN) {
    open(PROPLIST, '-|', 'svn', '--recursive', 'propget', 'svn:keywords', 'src')
        or die "Cannot open pipe to SVN: $!\n";
} else {
    open(PROPLIST, "svn --recursive propget svn:keywords src |")
        or die "Cannot open pipe to SVN: $!\n";
}


# --------------------------------------------------------------
#  Read list of file names and 'svn:keywords' properties.
#  Undefine entries of files which have default property, or
#  add entries if the respective files have non-default property.
# --------------------------------------------------------------

while (<PROPLIST>) {
    # Format of svn output:
    #     <file-name> <space> '-' <space> <svn-properties>
    #     ...
    # Sometimes(?) files without svn:keywords property won't be
    # displayed, their property values remain empty.
    chomp;
    if (/^(\S+) - *(\S.*)?$/) {
        if (defined $2) {
            $property{$1} = ($2 eq $Default_property) ? undef : $2
        } else {
            # Just in case...
            $property{$1} = "";
        }
    } else {
        die "Invalid SVN output: $_\n";
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

# Read list and prepare for output:
my %matches;
while ( (my $file, my $prop) = each(%property) ) {
    next unless defined $prop;	# skip files with default property
    $matches{$file} = ($prop && $verbose) ? " ($prop)" : ""; 
}

print STDERR "Found ", scalar keys(%matches),
             " file", ((scalar keys(%matches) != 1) ? "s" : ""),
             " with missing/wrong property",
             (scalar keys(%matches) > 0 ? ":" : "."), "\n"
    if $verbose;

# Print sorted list of matches:
foreach (sort keys(%matches)) {
    print $_, $matches{$_}, "\n";
}


# Exit code:
#       0  if no file without default property found,
#     128  if one or more files without default property found,
#       *  on error.
exit((scalar keys(%matches)) ? 128 : 0);


