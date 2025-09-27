#!/usr/bin/env perl
#
# gimp-help -- get translation status
# Copyright (C) 2008-2021 The GIMP Documentation Team.
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

(my $PROG = $0) =~ s,.*/,,;
my $VERSION = 0.05;

my %Languages = (
	bg => "Bulgarian",
	ca => "Catalan",
	cs => "Czech",
	da => "Danish",
	de => "German",
	el => "Greek",
	en_GB => "British English",
	eo => "Esperanto",
	es => "Spanish",
	fa => "Persian",
	fi => "Finnish",
	fr => "French",
	hr => "Croatian",
	hu => "Hungarian",
	it => "Italian",
	ja => "Japanese",
	ko => "Korean",
	lt => "Lithuanian",
	nb => "Norwegian",
	nn => "Norwegian",
	no => "Norwegian",
	nl => "Dutch",
	pl => "Polish",
	pt => "Portuguese",
	pt_BR => "Brazilian Portuguese",
	ro => "Romanian",
	ru => "Russian",
	sk => "Slovak",
	sl => "Slovenian",
	sv => "Swedish",
	tr => "Turkish",
	uk => "Ukrainian",
	zh_CN => "Simplified Chinese"
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
find( sub { /^\.git/ and ($File::Find::prune = 1)
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
	$ENV{"LC_ALL"} = "C";
	for (sort @Pofiles) {
		# XXX: is "--output-file=/dev/null" portable?
		my $statistics = `msgfmt --statistics --output-file=/dev/null $_ 2>&1`;
		# TODO: better do regex matching here?
		chomp $statistics;
		my $filesize = (lstat())[7] || 0;
		print "$_ $filesize $statistics\n";
	}
	# use this if there are problems with "msgfmt --output-file=/dev/null"
	#unlink "messages.mo" if -e "messages.mo" && @Pofiles;
	close STDOUT or die "ERROR: Cannot close pipe (w): $!\n";
	exit;
}

# Parent process
my ($translated, $size, $fuzzy, $untranslated) = (0) x 4;
my $msg_re = qr/^   (\S+) \s                     # $1 = filename
                    (\d+) \s                     # $2 = filesize
                    (\S+) \s translated   \D+    # $3 = translated msgs.
                (?: (\S+) \s fuzzy        \D+ )? # $4 = fuzzy msgs.
                (?: (\S+) \s untranslated \D+ )? # $5 = untranslated msgs.
                $/ix;
while (<MSGFMT>) {
	m/$msg_re/ or die("\n$PROG: ERROR matching msgfmt output '$_'\n");
	my ($n, $s, $t, $f, $u) = ($1, $2, $3, $4 || 0, $5 || 0);
	# print and save file statistics
	handle_file_statistics($n, $s, $t, $f, $u);
}
close MSGFMT or die "ERROR: Cannot close pipe (r): $!\n";
print_summary($translated, $fuzzy, $untranslated, $size);


# ------------------------------------------------------
sub handle_file_statistics
# ------------------------------------------------------
{
	my ($n, $s, $t, $f, $u) = @_;
        $size += $s;
	$translated += $t;
	$untranslated += $u;
	$fuzzy += $f;
	printf "%+5d  ~%-4d -%-4d %s\n", $t, $f, $u, $n
		unless !$Print_file_list ||
		       $Skip_translated && ($u + $f) == 0;
}

# ------------------------------------------------------
sub print_summary
# ------------------------------------------------------
{
	my ($translated, $fuzzy, $untranslated, $size) = @_;
	my $total = $translated + $fuzzy + $untranslated;

        if ($Print_summary) {
		print "\n" if $Print_file_list;
                printf "total: %d strings in %d files (%d Bytes):\n" .
                       "    translated=%d fuzzy=%d untranslated=%d\n",
                       $total, scalar @Pofiles, $size,
                       $translated, $fuzzy, $untranslated;
	}

	if ($Print_progress) {
		my $progress = int(($translated * 100 / $total) + 0.5);
		if ($progress == 100 && $translated < $total) { $progress = 99 }
		my $width = 50;
		$translated   = int($translated * $width / $total);
		$fuzzy        = int(     $fuzzy * $width / $total);
		$untranslated = $width - ($translated + $fuzzy);

		print "\n" if $Print_file_list || $Print_summary;
		printf "[%s%s%s]  %3d%%  %s\n",
		    ">" x $translated,
		    "~" x $fuzzy,
		    "_" x $untranslated,
		    $progress,
		    $Language;
	}
}


__END__

=head1 BUGS

The script has not been tested under BSD or Mac OS X.

=head1 AUTHOR

Ulf-D. Ehlert

=head1 COPYRIGHT

(C) 2008-2012 The GIMP Documentation Team.

License: GPL

=cut
