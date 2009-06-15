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
use File::Spec::Functions qw/abs2rel splitpath catfile/;
use File::Copy;


# Error message for command-line (usage) error:
my $Usage = "Usage: $0 [OPTIONS] srcdir [...] destdir\n" .
            "OPTIONS:\n" .
            "  -v | --verbose     print number of image files\n" .
            "                     (specify more than once for debugging)\n" .
            "  -m | --mode MODE   specify copy mode:\n" .
            "                     ('hardlink', 'symlink', or 'copy')\n";

# Command-line options (default values)
#
# If "-v" option is specified, the number of links will be displayed.
my $Verbose = 0;
# May be specified more than once (for debugging).
Getopt::Long::Configure("bundling");
# For now, language will be derived from destination directory
my $Language = undef;
# Mode may be "symlink", "hardlink", or "copy"
my $Mode = "symlink";

# Read command-line options
GetOptions(
	"verbose|v+" => \$Verbose,
	"mode|m=s"   => \$Mode,
) or die "$Usage\n";

# Check mode:
$Mode =~ /^symlink|hardlink|copy$/
    or die "Not a valid mode: $Mode\n";
# TODO: Use a list of modes with additional mode(s) as fallback?!

# Required args: one or more source directories,
#                one destination directory.
die "$Usage\n" if scalar @ARGV < 2;
my $Destdir = pop;
my @Srcdirs = @ARGV;

# XXX: assuming destination = '(x|ht)ml/LANG[/images]
if ($Destdir =~ s:((x|ht)ml)/([^/]+)(/images)?/?$:$1/$3:) {
    $Language = $3;
    $Language =~ /^[a-z]{2}(_[A-Z]{2})?$/
        or die "Invalid language: $Language\n";
} else {
    die "Invalid destination directory: $Destdir\n" .
        "  (should be '(x|ht)ml/LANG[/images]')\n";
}
if ($Verbose > 1) {
    print STDERR "Destination  = $Destdir\n", 
                 "Sources (en) = " . join(', ',  @Srcdirs) . "\n",
                 "Language     = $Language\n",
                 "Mode         = $Mode\n";
}

# Check for existance of directories:
foreach (@Srcdirs, $Destdir) {
    die "No such directory: $_\n" unless -d
}

# Create list of source directories:
my @Image_dirs;
find( sub { /^\.git/ and ($File::Find::prune = 1)
                             or
            -d and push(@Image_dirs, $File::Find::name) 
      },
      @Srcdirs );
die "Oops! Bug in search routine!\n" unless @Image_dirs;

# At verbose mode, the number of links will be displayed:
my ($Count_all, $Count_i18n) = (0, 0);
# See "perldoc -f symlink"
my $Symlink_exists = eval { symlink("",""); 1 };
my $Hardlink_works = undef;
my $Make_symlink   = ($Mode eq "symlink")  ? 1 : 0;
my $Make_hardlink  = ($Mode eq "hardlink") ? 1 : 0;
my $Make_copy      = ($Mode eq "copy")     ? 1 : 0;
my $Localize_image = ($Language ne "en")   ? 1 : 0;

# Main routine:
foreach my $srcdir (sort @Image_dirs) {
    # Construct corresponding destination directory:
    # XXX: assuming source = images/{C,common}
    #      and destination = xml/LANG
    (my $dstdir = $srcdir) =~ s|(.*/)?images/[^/]+|$Destdir/images|o;
    -d $dstdir or mkpath $dstdir
        or die "Cannot mkpath $dstdir: $!\n";
    # Get relative path from $dstdir to (image source directory) $srcdir;
    # this path is needed if/when making relative symlinks.
    my $save_path = my $dst_to_src_path = abs2rel($srcdir, $dstdir)
        if $Make_symlink;
    foreach my $imgfile (glob "$srcdir/*.*") {
        next unless -f $imgfile;
        my $basename = (splitpath($imgfile))[2];  # (vol, dir, file)
        my $destfile = catfile($dstdir, $basename);  # the new file/link
        # Check for existance of localized image:
        if ($Localize_image) {
            (my $localized_imgfile = $imgfile) =~ s|/C/|/$Language/|o;
            if (-e $localized_imgfile) {
                $imgfile = $localized_imgfile;
                ++$Count_i18n if $Verbose;
            }
        }
        print STDERR "$destfile\n" if $Verbose > 2;
        if ($Make_symlink) {
            # If necessary, change relative path too:
            $dst_to_src_path = $save_path;
            $dst_to_src_path =~ s|/C/|/$Language/|o
                if ($Localize_image && $imgfile =~ m|/$Language/|o);
            # Create relative symlink to image file:
            symlink(catfile($dst_to_src_path, $basename), $destfile)
                or die("Cannot symlink $destfile to $imgfile\n");
        } elsif ($Make_hardlink) {
            # Create hardlink to image file:
            link($imgfile, $destfile)
                or die("Error: Cannot link $imgfile to $destfile\n");
        } elsif ($Make_copy) {
            # Copy file - slow, but should always work ...
            File::Copy::syscopy($imgfile, $destfile)
                or die("Error: Cannot copy $imgfile to $destfile: $!\n");
        } else {
            die("Oops!? No working mode for linking/copying $imgfile!\n");
        }
        ++$Count_all if $Verbose;
    }
}

# print number or created links/copies:
print " ", $Count_all, ($Localize_image ? " ($Language: $Count_i18n)" : ""), "\n"
    if $Verbose;
