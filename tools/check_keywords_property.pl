#!/usr/bin/env perl
#
# check_keywords_property.pl
#
# This script checks for every xml file if the 'svn:keywords' property
# is set correctly.
#
# It calls "svn propget 'svn:keywords'" for every file and writes the
# file name to stdout if no property set, plus optionally property
# in parantheses if non-default property set.
#
# Usage:
#     cd <top_srcdir>  # where src/ and tools/ are
#     tools/check_keywords_property.pl [-v]
#                         or
#     perl tools/check_keywords_property.pl [-v]
#

require 5.008;	# for the special "open" list form used
use warnings;
use strict;
use Getopt::Long;
use File::Find;


# --------------------------------------------------------------
#  Variables and "constants"
# --------------------------------------------------------------

my $Default_property='Author Date Id Revision';
my %property;	# (filename, property) pairs
my $seen = "";	# any value except 'undef'
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

print STDERR "Searching for missing/wrong properties:\n",
             "    searching xml files ...\n"             if $verbose;

find( sub { /^\.svn/ and ($File::Find::prune = 1)
                             or
            /\.xml$/ and ($property{$File::Find::name} = $seen)
      },
      "src" );


# --------------------------------------------------------------
#  Print 'svn:keywords' property for every xml file
# --------------------------------------------------------------

print STDERR "    checking ", scalar keys %property, " xml files ...\n"
    if $verbose;

# See below for detailed description.
print_properties();

# --------------------------------------------------------------
#  The "print_properties()" subroutine produces a list of
#  file names and its 'svn:keywords' properties to be read
#  from the main program's STDIN:
#  (1) First a child is forked connected to STDIN.
#  (2) This child creates another process ("xargs svn ..."), and
#      pipes the list of file names stored in the %property hash
#      to it.
#  (3) The "xargs" process recieves this file list from STDIN
#      and executes
#          "xargs svn propget svn:keywords <file> ..."
#      to produce a list of file names and properties on STDOUT,
#      which is the main program's STDIN, due to (1).
# --------------------------------------------------------------

sub print_properties {
    my $pid = open(STDIN, '-|') and return;  # parent (reads from pipe)
    die "Cannot fork: $!\n" unless defined $pid;

    # pipe output to command
    open(PIPE_TO_XARGS_SVN, "|-",
         '/usr/bin/env',
         'xargs',
         'svn', 'propget', 'svn:keywords',
         # Format of "svn propget svn:keywords <file1> <file2> ... " output is
         #     <file_1> - <property>             
         #     ...
         #     <file_n> - <property>             
         # However, when there is only one remaining xargs argument, then we
         # will get the output (if any) from "svn propget svn:keywords <file>":
         #     <property>
         # So we insert an additional filename as argument, forcing the
         # argument list to have at least two elements:
         'src/gimp.xml'
    )
        or die "Cannot open pipe to SVN: $!\n";

    # Pass list of files to "xargs svn" process:
    foreach (keys %property) { print PIPE_TO_XARGS_SVN $_, "\n" }

    close(PIPE_TO_XARGS_SVN) or die "Cannot close pipe to SVN: $!\n";
    exit;
}

# --------------------------------------------------------------
#  Read list of file names and 'svn:keywords' properties
#  and add the properties to the %property hash
# --------------------------------------------------------------

while (<>) {
    # Format of svn output:
    #     <file-name> <space> '-' <space> <svn-properties>
    #     ...
    if (/^(\S+) - *([^[:space:]].*)?$/) {
        # 'undef' will indicate default property ("nothing to do")
        if (defined $2) {
            $property{$1} = ($2 eq $Default_property) ? undef : $2
        } else {
            $property{$1} = "";
        }
    }
}
close(STDIN) or die "Cannot close pipe from SVN: $!\n";


# --------------------------------------------------------------
#  Read the %property hash:
#      key:   file name
#      value: svn:keywords property:
#           undef  if default property
#              ""  if no property
#          string  if non-default property
# --------------------------------------------------------------

my %matches;

# Read list and prepare for output:
while ( (my $file, my $prop) = each(%property) ) {
    next unless defined $prop;	# skip files with default property
    $matches{$file} = ($prop && $verbose) ? " ($prop)" : ""; 
}

print STDERR "Found ", scalar keys %matches,
             " file", (keys %matches != 1 ? "s" : ""),
             " with missing/wrong property",
             (keys %matches > 0 ? ":" : "."), "\n"    if $verbose;
# Print sorted list of matches:
foreach (sort keys(%matches)) {
    print $_, $matches{$_}, "\n";
}


# Exit code:
#       0  if no file without default property found,
#     254  if one or more files without default property found,
#       *  on error.
exit((scalar keys(%matches)) ? 254 : 0);


