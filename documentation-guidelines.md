# gimp-help documentation guidelines

### Table of Contents
1. [Style guide](#style-guide)
2. [Image handling](#image-handling)
3. [Moving documentation](#moving-documentation)

## Style guide

- Most lines should be no longer than 80 characters, except for long literal
  strings like website links.
- Do not use TAB characters.
- Do not add spaces at end of a line. If the sentence continues on the next
  line, Docbook is smart enough to add a space.
- Use only Linux line endings.
- Tags starting a block of text or other group should begin on a new line
  and indented from its parent block.
- Indentation should be two spaces.
- Do not use two consecutive spaces to separate sentences or anywhere else
  inside a sentence.
- Do not add a space before a ':' or other punctuation.
- Use American English spelling.
- Titles and Headings should use "Title-style Capitalization" rules,
  i.e. capitalize major words and the first and last word of the title
  or heading.
- Do not put a period at the end of a Title or Heading.
- Documentation does not need to reference back to anything before the current
  main version (currently 3.0). So, things like "Since GIMP 2.6 you can do ..."
  should be changed to not mention the GIMP version. Changes in a minor version
  can be added ("this option was added in 3.0.4"), but should probably only
  be done sparingly, since these remarks become obsolete in the next major
  version.
- Don't use "grayed out" or similar to denote a disabled item. The color depends
  on the user's theme. Use "disabled" instead. Note: don't blindly replace
  it, there are valid cases of grayed out, e.g. in sample-colorize.
- Use grayscale instead of gray scale or gray-scale. Do not use grayscaled.
- GIMP should be referenced as `<acronym>GIMP</acronym>`. The name is always
  written in all uppercase. We do not add 'the' in front of it anymore. In the
  rare case you need to mention the version number, do it like this:
  `<acronym>GIMP</acronym> 2.10`, do not add a dash.
- Referencing GEGL should be done in the same way.
- Use of `<xref linkend="id"/>` is discouraged. Translators won't know what the
  text of the link will be, which makes it more difficult for them to put it
  in the correct order in the translated sentence.
  Use `<link linkend="id">link text</link>` instead.
- Do not use "image menu" or similar to denote the main menu. Call it
  "main menu" instead. It can be confusing and is ambiguous since there is an
  "Image" submenu in the main menu.
  Historically, when GIMP was multi-window only, it may have made more sense to
  call it that, but that is no longer the case.
- Never ever say "self explanatory" or something with a similar meaning. Always
  use an actual description, even if it means mostly repeating the option
  label or other relevant text.
- Most documentation pages are structured the same way. Try to use the same
  sentences where possible to reduce work for translators.
- Strings to be translated are in general divided per paragraph. Sometimes it
  can be advantagous to split a paragraph in two if it means that one part
  can be reused in other parts of the documentation and thus reducing work
  for translators.
- Certain parts of the documentation are platform specific. We need to be
  clear about this when this is the case and where necessary explain it for
  each platform separately, e.g. when mentioning file paths.
- On macOS different names are used for the Ctrl and Alt keys. We currently
  do not document this, but we should investigate how to improve this without
  too much effort. If this could be done inside docbook xml automatic handling,
  that would be perfect.
- In the past `section history` comments were added at the top of the source
  documentation xml files. Don't use or update these sections. Our history
  can easily be followed by checking the commit log.
- More technical Docbook related info can be found in [HACKING](HACKING).

## Image handling

- If you remove the reference to an image from the documentation, don't forget
  to actually delete the image (unless it is used elsewhere in the
  documentation, which should be checked first).
- You should also check if that image has translated versions. These should be
  removed too.
- There is a make target to check for unused (orphaned) images:
  `make check-images-en` to check the original images, replace `en` with
  your language of choice to check for translated images in that language.
  At this moment, there is no target to check all languages at once,
  feel free to contribute this.
- If you update an image with text where that text has changed considerably,
  e.g. dialogs with new options, you should look at the translated images too.
  If they are too different, it's probably better to remove them to show the
  up-to-date English image.
- Try not to add dialog images or other images with text, that can be
  documented well enough without showing an image. Because every image with
  text needs a translated version for each language that we support.
  In certain cases you may be able to split one image with text into a part
  that has text and a part without that doesn't need to be translated.
- Images that show the interface should use the default theme and icon theme.
  A lot of people using image editors seem to prefer a dark theme over a light
  theme, but we accept both. Just try to be consistent inside the same section
  of the documentation with other recently added images. Changes to images only
  to make them consistent should first be discussed in an issue or MR.
- Where possible, exclude the window decorations from screenshots. The window
  borders are often the most notable differences between Platforms. We should
  not distract users with this when we can, e.g. most filter options dialogs.
- Similarly, if we need multiple screenshots where one part always stays the
  same, we should only show the relevant part.
- Images that mostly show our interface can often be exported as indexed png,
  without losing much in quality. This saves storage space and keeps downloads
  smaller for our users. If you decide to use indexed, make sure that it doesn't
  degrade the image quality too much.
- File sizes, download speeds and bandwidth are still relevant in certain parts
  of the world. On top of that, git without large file support is not very well
  suited for many large binary blobs like images. It can degrade the performance
  of repository cloning and updating. All reasons, to try to keep the image
  sizes down and not to update images too often.
- Be aware that some dialogs can differ between platforms or even be only
  available on some platforms, e.g. the print dialog, debug preferences, etc.
  This should be clearly mentioned in the documentation.
- When creating a new image please:
  + Make the name all lowercase.
  + Use a dash/minus sign to connect words; do not use underscores.
  + Use complete words, not abbreviations, e.g. `rectangle-select` instead
    of `rectsel`, except when naming stock icons (in which case we keep the
    same name as used in GIMP).
  + Start the name with the generic part, that way images about the same
    subject will be sorted together, e.g. start with `tool-options` followed
    by the specific subject of the image, instead of ending with it.
  + All stock icons as used by GIMP should be added in the `stock-icons` folder,
    and use the same name as used by GIMP. These images do not need to be
    localized.

## Moving documentation

When reorganizing the manual, we may need to move certain parts of our
documentation to a new location. We need to be aware of the effects of moving
documentation on translations.

Since translations of our manual are divided in many sections, which each
have their own po file with translations, moving documentation could mean
that it now belongs to a different po file.

If we don't take any special action, certain parts that were already translated,
will have to be translated again. We would prefer not to cause unnecessary
extra work for translators, so we should try to copy over the translations
from the old po file to the new one.

The following procedure explains how to do this move:

1. Announce your intent to translators on https://discourse.gnome.org/, make
   sure to use the i18n and gimp tags, and give them some time (a week?), so
   they can get pending translations in.
2. We need up-to-date po-files. Make sure to touch all files in /src first,
   because `make po` doesn't always work since po files are usually only updated
   when new translations get in, and thus can get out-of-sync. After that run
   `make po`.
   For a script to touch all src files, see [^1].
3. For all languages, make a copy of the po files that currently contain the
   translations that are to be moved. See example script [^2] below.
4. Move the documentation to its new location.
5. Regenerate all pot and po files (`make pot`, `make po`).
6. Use msgmerge with the saved old po files as compendium to merge the
   translations from the old saved po files from step 2.
   `msgmerge --compendium comp.po new-loc.po new-loc.pot -o new-loc.po`
   See example script [^3].
7. Remove the copies of the po files used as compendium, and if any of the
   old po files are not used anymore, also remove those.
8. Commit everything in a separate branch.
9. make validate to make sure everything works. You can let this be done by
   the MR, since this whole change should be done as an MR anyway. This should
   not be merged without approval of a maintainer.
10. A next step, if the above has been finished successfully, is to update
    the locations of referenced images. Since the move won't break showing
    images from the old location, we will do this separately.
    Move the images in /images/C/ used in the old documentation to the new
    location relevant to where the documentation now resides.
    Do the same for all translated versions of images.
    Make sure to check that all images are still found when building. If they
    are not, our CI should fail.
11. After the documentation has been moved, check the documentation that
    references the moved parts to see if parts of it need to be adjusted.

###Footnotes
The bash scripts in the footnotes are examples. They don't pretend to be
optimized (my bash knowledge is limited).
You may need to adjust them to your system and the files that need to be moved.
Feel free to suggest improvements.

[^1]: Mark all source XML files as updated.
    ```
    cd ~/gimp-help/src

    #Mark all source files as updated...
    find . -type f -exec touch {} +
    ```

[^2]: Copy po files.

    ```sh
    # Copy po translations to be used as compendium

    SRCDIR=/home/Jacob/gimp-help/po/

    #1. Go to gimp-help
    cd $SRCDIR

    #2. For all available po language dirs
    #3. For the selected po files copy them to compendium-xxx.po

    COPY_FILES="concepts using"

    # Only copying to/from 1 subdir supported atm
    COPY_FILES_SUB="preferences"
    SUBDIR=using

    # Only copying to/from 1 subdir supported atm
    COPY_FILES_SUB2="file"
    SUBDIR2=menus


    for podir in ./*; do
        echo "Language dir $podir"
        for file_to_copy in $COPY_FILES; do
            echo "Copying $file_to_copy.po to compendium-$file_to_copy.po"
            cp $SRCDIR/$podir/$file_to_copy.po $SRCDIR/$podir/compendium-$file_to_copy.po
        done

        # same when needing to copy to a subdir (can't be bothered to figure it out in 1 loop)
        for file_to_copy in $COPY_FILES_SUB; do
            echo "Copying $file_to_copy.po to compendium-$file_to_copy.po"
            cp $SRCDIR/$podir/$SUBDIR/$file_to_copy.po $SRCDIR/$podir/$SUBDIR/compendium-$file_to_copy.po
        done

        # same when needing to copy to a subdir (can't be bothered to figure it out in 1 loop)
        for file_to_copy in $COPY_FILES_SUB2; do
            echo "Copying $file_to_copy.po to compendium-$file_to_copy.po"
            cp $SRCDIR/$podir/$SUBDIR2/$file_to_copy.po $SRCDIR/$podir/$SUBDIR2/compendium-$file_to_copy.po
        done
    done
    ```

[^3]: Merge old translations to the new location.
    ```sh
    # Merge compendium translations to destination po files

    SRCDIR=/home/Jacob/gimp-help/po
    POTDIR=/home/Jacob/build/gimp-help/pot

    #1. Go to gimp-help
    cd $SRCDIR

    #2. For all available po language dirs
    #3. For the selected po files copy them to compendium-xxx.po

    COMPENDIUM_FILES="compendium-concepts.po compendium-using.po using/compendium-preferences.po menus/compendium-file.po"
    comp_array=($COMPENDIUM_FILES)
    DEST_FILES="dialogs.po dialogs.po dialogs.po dialogs.po"
    dest_array=($DEST_FILES)
    POT_FILES="dialogs.pot dialogs.pot dialogs.pot dialogs.pot"
    pot_array=($POT_FILES)


    for podir in ./*; do
        echo "Language dir $podir"

        #msgmerge --compendium file dest-location.po dest-location.pot -o dest-location.po
        i=0
        # BEWARE: the number below needs to be updated to reflect the actual number of files!
        while [[ i -lt 4 ]]; do
            echo ${comp_array[$i]}
            msgmerge --compendium $SRCDIR/$podir/${comp_array[$i]} $SRCDIR/$podir/${dest_array[$i]} $POTDIR/${pot_array[$i]} -o $SRCDIR/$podir/${dest_array[$i]}
            ((i++))
        done

    done
    ```
