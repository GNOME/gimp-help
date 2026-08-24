#!/bin/bash
#
# Copy images
#
# Copyright (C) 2026 The GIMP Documentation Team.
# License: GPL
#
# Arguments (starting at 1)
# $1 - source root (to source images)
# $2 - build dest folder (where to add dest images folder)
# $3 - flags (flags to add when calling make_image_links.pl)
# $4 - language code

source_root=$1
build_folder=$2
flags=$3
lang=$4

# Where to look for source images
source_image_folders=("$source_root/images/common" "$source_root/images/C")
# and destination
dest_lang_folder=$build_folder/$lang
dest_image_folder=$build_folder/$lang/index.html.p/images

# DEBUG
#echo "Dest: $dest_image_folder"
#echo "Sources: ${source_image_folders[@]}"
#echo "Flags: $flags"


# 2 remove old destination images, including symbolic link files and folders
# xml/%/images: $(IMAGE_PREREQ)
# 	$(cmd) if test -L $@; then rm -v $@; fi
# 	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
# 	$(cmd) if test -d $@; then rm -rf $@/*; fi
# 	$(cmd) test -d $@ || $(MKDIR_P) $@

if [ -L "$dest_image_folder" ]; then rm -v $dest_image_folder; fi
if [ -L "$dest_lang_folder" ]; then rm -v $dest_lang_folder; fi
if [ -d "$dest_image_folder" ]; then rm -rf ${dest_image_folder}/*; fi
if [ ! -d "$dest_image_folder" ]; then mkdir -p ${dest_image_folder}; fi

# 3 copy images to destination
perl $source_root/make.d/make_image_links.pl $flags ${source_image_folders[@]} $dest_image_folder || exit 1

# 4 touch images
touch $dest_image_folder
