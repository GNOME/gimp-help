#!/usr/bin/env perl
#
# gimp-help-2 -- get translation status
# Copyright (C) 2008 The GIMP Documentation Team.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

=head1 NAME

get_po_status.pl - print po files along with translation statistics

=head1 SYNOPSIS

[B<perl>] B<get_po_status.pl> [B<--todo>] I<PO-DIRECTORY>

=head1 DESCRIPTION

This script searches for po files in the specified directory
and prints a sorted list of files with translation statistics
(generated with C<msgfmt --statistics>) in the following format:

	+n1 ~n2 -n3  path/to/file.po

where C<n1> is the number of translated po messages, C<n2> the
number of fuzzy messages, and C<n3> the number of untranslated
messages.

By default the script also prints a short summary.

=cut


use warnings;
use strict;
use Getopt::Long;
use File::Find;


my $PROG = $0;

=head1 OPTIONS

=over 4

=item B<--todo>

Skip files without untranslated or fuzzy messages.

=back

=cut

my $Usage =<<EOF;
Usage: $PROG [OPTIONS] PODIR
Options:
	--todo    Skip files without untranslated or fuzzy messages.
EOF

# Command-line options (default values)
my $Skip_translated = 0;

# Read ccommand-line options
GetOptions(
	"todo" => \$Skip_translated
) or die "$Usage\n";

# Read ccommand-line argument
my $Podir;
if (scalar(@ARGV) == 1) {
	$Podir  = $ARGV[0];
	die "ERROR: No such directory: $Podir\n"
		unless -d "$Podir";
} else {
	 die "ERROR: Missing argument\n\n" . "$Usage\n";
}

# Search po files
my @Pofiles = ();
find( sub { /^\.svn/ and ($File::Find::prune = 1)
                               or
            /\.po$/ and push @Pofiles, $File::Find::name
      },
      $Podir );
scalar @Pofiles > 0 or die "ERROR: No pofiles found.\n";

# Create a child process which runs 'msgfmt' on every
# po file and writes output via pipe to parent process.

my $pid = open(MSGFMT, "-|");
die "ERROR: Cannot fork: $!\n" unless defined $pid;

if ($pid == 0) {
	# Child process
	$ENV{"LANG"} = "C";
	for (sort @Pofiles) {
		my $statistics = `msgfmt --statistics $_ 2>&1`;
		# TODO: better do regex matching here?
		chomp $statistics;
		print "$_ $statistics\n";
	}
	close STDOUT or die "ERROR: Cannot close pipe (w): $!\n";
	exit;
}

# Parent process
my ($translated, $fuzzy, $untranslated) = (0, 0, 0);
my $msg_re = qr/^   (\S+) \s                     # $1 = filename
                    (\S+) \s translated   \D+    # $2 = translated msgs.
                (?: (\S+) \s fuzzy        \D+ )? # $3 = fuzzy msgs.
                (?: (\S+) \s untranslated \D+ )? # $4 = untranslated msgs.
                $/ix;
while (<MSGFMT>) {
	m/$msg_re/ or die("ERROR matching msgfmt output '$_'\n");
	my ($n, $t, $f, $u) = ($1, $2, $3 || 0, $4 || 0);
	print_file_statistics($n, $t, $f, $u);
}
close MSGFMT or die "ERROR: Cannot close pipe (r): $!\n";
print_summary($translated, $fuzzy, $untranslated);


# ------------------------------------------------------
sub print_file_statistics
# ------------------------------------------------------
{
	my ($n, $t, $f, $u) = @_;
	$translated += $t;
	$untranslated += $u;
	$fuzzy += $f;
	printf "%+4d  ~%-2d -%d\t%s\n", $t, $f, $u, $n
		unless $Skip_translated && ($u + $f) == 0;
}

# ------------------------------------------------------
sub print_summary
# ------------------------------------------------------
{
my $total = $translated + $fuzzy + $untranslated;

	print STDERR
	      "\n",
	      "total: ", $total, " strings in ",
	      scalar @Pofiles, " files:\n    ",
	      "translated=", $translated, " ",
	      "fuzzy=", $fuzzy, " ",
	      "untranslated=", $untranslated, " ",
	      "\n";

	my $progress = int(($translated * 100 / $total) + 0.5);
	if ($progress == 100 && $translated < $total) { $progress = 99 }
	my $width = 50;
	$translated   = int(  $translated * $width / $total);
	$untranslated = int($untranslated * $width / $total);
	$fuzzy        = int(       $fuzzy * $width / $total);
	($translated + $untranslated + $fuzzy == $width) or ++$untranslated;

	print STDERR
	      "\n", "[",
	      ">" x $translated,
	      "~" x $fuzzy,
	      "_" x $untranslated,
	      "]", "  ",
	      $progress, "%",
	      "\n\n";
}


__END__

=head1 BUGS

The script has not been tested under Microsoft Windows or Mac OS X.

=head1 AUTHOR

Ulf-D. Ehlert

=head1 COPYRIGHT

(C) 2008 The GIMP Documentation Team.

License: GPL

=cut
