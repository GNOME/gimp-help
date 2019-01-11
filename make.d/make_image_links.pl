#!/usr/bin/env perl
#
# make_image_links.pl
#
# This script creates relative symlinks in xml/LANG to images files
# in images/C and images/common.
#
# Do not use this script directly, it's meant to be run by 'make'.
#
# Usage:
#     cd <top_srcdir>  # where src/ and tools/ are
#     tools/make_image_links.pl [-v] images/C images/common xml/LANG
#

use warnings;
use strict;
use Getopt::Long;
use File::Find;
use File::Path qw/mkpath/;
use File::Spec::Functions qw/abs2rel rel2abs splitpath catfile/;
use File::Copy;


# Error message for command-line (usage) error:
my $Usage = <<EOF;
Usage: $0 [OPTIONS] srcdir [...] destdir
OPTIONS:
  -v|--verbose     print number of processed image files
                   (specify more than once for debugging messages)
  -m|--mode MODES  comma-separated list of methods to copy image files,
                   valid modes are 'hardlink', 'symlink', and 'copy'
EOF

# Command-line options (default values)
#
# If "-v" option is specified, the number of links will be displayed.
my $Verbose = 0;
# '-v' may be specified more than once (for debugging).
Getopt::Long::Configure("bundling");
# For now, language will be derived from destination directory
my $Language = undef;
# Mode is a list containing "symlink", "hardlink", and/or "copy"
my @Mode = ();
# See "perldoc -f symlink"
my $SYMLINK_EXISTS = eval { symlink("",""); 1 };

# Read command-line options
GetOptions(
	"verbose|v+" => \$Verbose,
	"mode|m=s"   => sub { @Mode = split(/,/, $_[1])
                                  or die "Error: empty mode\n"
                            }
) or die "$Usage\n";

# Check mode:
if (my @tmp_mode = @Mode) {
    @Mode = ();
    foreach (@tmp_mode) {
        m/^symlink|hardlink|copy$/
            or die "Error: not a valid mode: $_\n";
        if (m/^symlink/ && !$SYMLINK_EXISTS) {
            warn "Warning: Symbolic links are not supported.\n";
            next;
        }
        push @Mode, $_;
    }
    die "Error: No working mode given. Abort. \n" unless @Mode;
} else {
    @Mode = ("symlink", "hardlink", "copy");
    shift @Mode unless $SYMLINK_EXISTS;
}

# Required args: one or more source directories,
#                one destination directory.
die "$Usage\n" if scalar @ARGV < 2;
my $Destdir = pop;
my @Srcdirs = @ARGV;

# assuming destination = (x|ht)ml/LANG[/images]
my $locale_re = qr/[a-z]{2}(?:_[A-Z]{2})?/;
if ($Destdir =~ s!((?:x|ht)ml)/($locale_re)(?:/images/?)?$!$1/$2!) {
    $Language = $2;
} else {
    die "Error: invalid destination directory: $Destdir\n" .
        "  (should be '(x|ht)ml/LANG[/images]')\n";
}
if ($Verbose > 1) {
    print STDERR "Destination  = $Destdir\n",
                 "Sources (en) = " . join(', ',  @Srcdirs) . "\n",
                 "Language     = $Language\n",
                 "Mode(s)      = ", join(' ', @Mode), "\n";
}

# Check for existence of directories:
foreach (@Srcdirs, $Destdir) {
    die "Error: no such directory: $_\n" unless -d
}

# Create list of source directories:
my @Image_dirs;
find( sub { /^\.git/ and ($File::Find::prune = 1)
                             or
            -d and push(@Image_dirs, $File::Find::name)
      },
      @Srcdirs );
die "Oops!? Bug in search routine?\n" unless @Image_dirs;

# At verbose mode, the number of links will be displayed:
my ($Count_all, $Count_i18n, $inc_i18n) = (0, 0, 0);

# Should we look for localized images?
my $Localize_images = ($Language ne "en") ? 1 : 0;

# The appropriate method for linking/copying is
# called via this reference to an (anonymous) subroutine
my $exec_copy_command = undef;

# Anonymous subroutines for calling the proper Perl command
my %method = ("symlink"  => sub { my ($s, $d) = @_; symlink($s, $d); },
              "hardlink" => sub { my ($s, $d) = @_;    link($s, $d); },
              "copy"     => sub { my ($s, $d) = @_;
                                  File::Copy::syscopy($s, $d); },
             );
# Create an anonymous subroutine for copying/linking according
# to the specified parameter ("symlink", "hardlink", or "copy")
sub get_copy_command {
    my $cur_mode = shift or die "Oops!?";
    # Simple check if we should try a fallback or abort
    # if copying/linking image failed
    my $mode_is_known_to_work = 0;
    return sub {
        my $ok = $method{$cur_mode}->(@_);
        if ($ok) {
            ++$mode_is_known_to_work;
        } else {
            warn("Error: failed to make $cur_mode for $_[0]\n");
            die("Abort.\n") if ($mode_is_known_to_work); # XXX: what else?
        }
        return $ok;
    }
}

# Subroutine for (re)setting copy/link mode
sub set_copy_mode {
    if (defined($exec_copy_command)) {
        # Fallback
        my $oldmode = shift @Mode;
        die "Error: no fallback for '$oldmode' mode. Abort.\n"
            unless @Mode;
        warn("Warning: '$oldmode' mode failed, " .
             "falling back to '$Mode[0]' mode.\n");
    }
    $exec_copy_command = get_copy_command($Mode[0]);
}

# Main routine:
set_copy_mode();
foreach my $srcdir (sort @Image_dirs) {
    # Construct corresponding destination directory,
    # assuming source = [.../]images/{C,common}
    #     destination = (x|ht)ml/LANG
    (my $dstdir = $srcdir) =~ s|(.*/)?images/[^/]+|$Destdir/images|o;
    -d $dstdir or mkpath $dstdir
        or die "Error: cannot mkpath $dstdir: $!\n";
    # Get relative path from $dstdir to (image source directory) $srcdir;
    # this path is needed if/when making relative symlinks.
    # FIXME: change this code, File::Spec::Unix is buggy(?!) --
    # abs2rel($srcdir, $dstdir) doesn't work if $srcdir starts with "../"
    my $dst_to_src_symlink_path =
        abs2rel(rel2abs($srcdir), $dstdir) if $Mode[0] eq "symlink";
    foreach my $imgfile (glob "$srcdir/*.*") {
        next unless -f $imgfile;
        my $basename = (splitpath($imgfile))[2];  # (vol, dir, file)
        my $destfile = catfile($dstdir, $basename);  # the new file/link
        # Check for existence of localized image:
        if ($Localize_images) {
            (my $localized_imgfile = $imgfile) =~ s|/C/|/$Language/|o;
            $inc_i18n = (-e $localized_imgfile) ? 1 : 0;
            $imgfile = $localized_imgfile if -e _;  # if $inc_i18n;
        }
        print STDERR "$destfile\n" if $Verbose > 2;
        # Special case symlinks:
        if ($Mode[0] eq "symlink") {
            my $dst_to_src_path = $dst_to_src_symlink_path;
            # If necessary, change relative path too:
            $dst_to_src_path =~ s|/C/|/$Language/|o
                if ($Localize_images && $imgfile =~ m|/$Language/|o);
            # Use a relative symlink to image file:
            $imgfile = catfile($dst_to_src_path, $basename);
        }
        my $ok = $exec_copy_command->($imgfile, $destfile);
        if (!$ok) {
            set_copy_mode();
            redo;
        }
        ++$Count_all  if $Verbose;
        ++$Count_i18n if $Verbose and $inc_i18n;
    } # foreach imgfile
} # foreach srcdir

# print number or created links/copies:
print " ", $Count_all, ($Localize_images ? " ($Language: $Count_i18n)" : ""), "\n"
    if $Verbose;
