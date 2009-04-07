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
use File::Find;
use File::Path qw/mkpath/;
use File::Spec::Functions qw/abs2rel splitpath catfile/;


# Error message for command-line (usage) error:
my $Usage = "Usage: $0 [-v] srcdir [...] destdir";
# If "-v" option is specified, the number of links will be displayed.
my $Verbose = 0;
if (@ARGV && $ARGV[0] =~ /-v|--verbose/) {
    $Verbose = 1;
    shift;
}
# Required args: one or more source directories,
#                one destination directory.
die "$Usage\n" if scalar @ARGV < 2;
my $Destdir = pop;
$Destdir =~ s|(/images)?/?$||;
my @Srcdirs = @ARGV;

# Check for existance of directories:
foreach (@Srcdirs, $Destdir) {
    die "No such directory: $_\n" unless -d
}

# XXX: assuming destination = xml/LANG[/images]
(my $Language = $Destdir) =~ s|.*/([^/]+)/?$|$1|;
my $Translatable = (($Language =~ /^[a-z]{2}(_[A-Z]{2})?$/) &&
                    ($Language ne "en"));

# Create list of source directories:
my @Image_dirs;
find( sub { /^\.svn/ and ($File::Find::prune = 1)
                             or
            -d and push(@Image_dirs, $File::Find::name) 
      },
      @Srcdirs );
die "Oops! Bug in search routine!\n" unless @Image_dirs;

# See "perldoc -f symlink"
my $Symlink_exists = eval { symlink("",""); 1 };
# If verbose mode, the number of links will be displayed:
my ($Count_all, $Count_i18n) = (0, 0);

# Main routine:
foreach my $srcdir (sort @Image_dirs) {
    # Construct corresponding destination directory:
    # XXX: assuming source = images/{C,common}
    #      and destination = xml/LANG
    (my $dstdir = $srcdir) =~ s|(.*/)?images/[^/]+|$Destdir/images|o;
    mkpath $dstdir unless -d $dstdir;
    # Get relative symlink pointing to image source directory
    my $save_path = my $dst_to_src_path = abs2rel($srcdir, $dstdir);
    foreach my $imgfile (glob "$srcdir/*.*") {
        next unless -f $imgfile;
        # Check for existance of localized image:
        if ($Translatable) {
            $dst_to_src_path = $save_path;
            (my $localized_imgfile = $imgfile) =~ s|/C/|/$Language/|o;
            $dst_to_src_path =~ s|/C/|/$Language/|o if -e $localized_imgfile;
            ++$Count_i18n if $Verbose && -e _;
        }
        my $basename = (splitpath($imgfile))[2];  # (vol, dir, file)
        # Create relative symlink to image file:
        symlink(catfile($dst_to_src_path, $basename),
                catfile($dstdir, $basename));
        # XXX: this can be expanded to (an optimized version of)
        #      "try hardlink, then symlink, then copy":
        #          link(source, destination)
        #                      or
        #          $Symlink_exists and symlink(source, destination)
        #                      or
        #          copy(source, destination);
        ++$Count_all if $Verbose;
    }
}

# print number or created symlinks:
print " ", $Count_all, ($Translatable ? " ($Language: $Count_i18n)" : ""), "\n"
    if $Verbose;
