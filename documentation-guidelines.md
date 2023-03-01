gimp-help documentation guidelines
==================================

Style guide
-----------
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
- Documentation does not need to reference back to anything before the current
  main version (currently 2.10). So, things like "Since GIMP 2.6 you can do ..."
  should be changed to not mention the GIMP version. Changes in a minor version
  can be added ("this option was added in 2.10.20"), but should probably only
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
- More technical Docbook related info can be found in [HACKING](HACKING).

Image handling
--------------
- If you remove the reference to an image from the documentation, don't forget
  to actually delete the image (unless it is used elsewhere in the
  documentation, which should be checked first).
- You should also check if that image has translated versions. These should be
  removed too.
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
  of the documentation.
- Images that mostly show our interface can often be exported as indexed png,
  without losing much in quality. This saves storage space and keeps downloads
  smaller for our users, which can be important in certain parts of the world
  that have limited bandwidth. If you decide to use indexed, make sure that
  it doesn't degrade the image quality too much.