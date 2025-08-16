subdir('C')
subdir('common')


# Setting for updating/adding images:
# - lazy: fast and lazy: detect added or removed images, but may miss changed images
# - force: always update images
# - strict (default): detects added, removed, or changed images

# We are probably going to ignore this if we can figure out how to use
# meson directly to copy the images and leave symlinks for another time
# to figure out.
image_update_flag = 'strict'

## Procedure for generator:
# 1. Collect all images from /C/
# 2. For non-en replace images with the same in /lang/ where available
# 3. Add images in /common/
# 4. They need to be made available in a subdir of where the /xml/lang/ images are
#    and keep the folder structure
# 5. Also same for /html/lang/


# Since it doesn't look like we can directly generate it to the same private
# dir as the XML is generated to.
# Maybe we generate/output it to /html/lang/images and from there an extra
# custom target copies it to our guessed private dir. Very hackish but that
# seems like the best we can do atm. We need the /images/ subdir in the
# xml directory
