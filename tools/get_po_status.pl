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
my $VERSION = 0.01;

my %Languages = (
	de => "German",
	es => "Spanish",
	fi => "Finnish",
	fr => "French",
	hr => "Croatian",
	it => "Italian",
	ko => "Korean",
	lt => "Lithuanian",
	nb => "Norwegian",
	no => "Norwegian",
	nl => "Dutch",
	pl => "Polish",
	ru => "Russian",
	sv => "Swedish",
);

=head1 OPTIONS

=over 4

=item B<--lang> I<language>

Language code ("de", "es", etc.) or language name.

=item B<--files> | B<--nofiles>

Whether or not to print file statistics; defaults to "yes".

=item B<--todo>

Skip files without untranslated or fuzzy messages.

=item B<--summary> | B<--nosummary>

Whether or not to print a short summary; defaults to "yes".

=item B<--progress> | B<--noprogress>

Whether or not to print a kind of progress bar, visualizing
the translation process; defaults to "yes".

=back

=cut

my $Usage =<<EOF;
Usage: $PROG [OPTIONS] PODIR
Options:
	--lang=LANG     Language code (e.g. "de" for German)
	--[no]files     Whether or not to print file statistics [default: yes]
	--todo          Skip files without untranslated or fuzzy messages
	--[no]summary   Whether or not to print a summary [default: yes]
	--[no]progress  Whether or not to print a progress bar [default: yes]
EOF

# Command-line options (default values)
my $Language        = undef;
my $Print_file_list = 1;
my $Skip_translated = 0;
my $Print_summary   = 1;
my $Print_progress  = 1;

# Read command-line options
GetOptions(
	"lang=s"    => \$Language,
	"files!"    => \$Print_file_list,
	"todo"      => \$Skip_translated,
	"summary!"  => \$Print_summary,
	"progress!" => \$Print_progress,
) or die "$Usage\n";

# Read command-line argument
my $Podir;
if (scalar(@ARGV) == 1) {
	$Podir  = $ARGV[0];
	die "ERROR: No such directory: $Podir\n"
		unless -d "$Podir";
} else {
	 die "ERROR: Missing argument\n\n" . "$Usage\n";
}

($Language = $Podir) =~ s|.*/([a-z]{2}(_[A-Z]{2})?)/?|$1| unless $Language;
$Language = $Languages{$Language} if defined($Languages{$Language});

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
		unless !$Print_file_list ||
		       $Skip_translated && ($u + $f) == 0;
}

# ------------------------------------------------------
sub print_summary
# ------------------------------------------------------
{
	my ($translated, $fuzzy, $untranslated) = @_;
	my $total = $translated + $fuzzy + $untranslated;

        if ($Print_summary) {
		print "\n" if $Print_file_list;
		print
		    "total: ", $total, " strings in ",
		    scalar @Pofiles, " files:\n    ",
		    "translated=", $translated, " ",
		    "fuzzy=", $fuzzy, " ",
		    "untranslated=", $untranslated, " ",
		    "\n";
	}

	if ($Print_progress) {
		my $progress = int(($translated * 100 / $total) + 0.5);
		if ($progress == 100 && $translated < $total) { $progress = 99 }
		my $width = 50;
		$translated   = int($translated * $width / $total);
		$fuzzy        = int(     $fuzzy * $width / $total);
		$untranslated = $width - ($translated + $fuzzy);

		print "\n" if $Print_file_list || $Print_summary;
		printf "[%s%s%s]  %2d%%  %s\n",
		    ">" x $translated,
		    "~" x $fuzzy,
		    "_" x $untranslated,
		    $progress,
		    $Language;
	}
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
