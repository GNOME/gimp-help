# GIMP-Help

GIMP-Help is a help system designed for use with the internal GIMP help
browser, external web browser and HTML renderers.
[DocBook](https://docbook.org/) is used to create a highly customizable documentation system.

The current manual documents features for the 2.99 development branch of
GIMP which is a moving target for the future GIMP 3.0.
The manual for GIMP 2.10 is also still being maintained in a separate branch
called `gimp-help-2-10`.

## Contents

1. [Published manuals](#published-manuals)
2. [Tips for contribution](#tips-for-contribution)
  2.1 [Translating](#how-to-help-translating-the-manual)
  2.2 [Manual writing](#how-to-help-writing-the-manual)
3. [Documentation issues](#documentation-issues)
4. [Creating a Release](#creating-a-release)
5. [Updating supported languages](#updating-supported-languages)
6. [ODF Files](#odf-files)
7. [History of the gimp-help module](#history-of-the-gimp-help-module)


## Published manuals

The most recent manuals for all supported languages are available at:

  https://www.gimp.org/docs/
  and
  https://docs.gimp.org/

We intend to integrate both pages and want to be able to automatically have
up to date manuals published there too, but we are still working on that.


## Tips for contribution

### How to help translating the manual

If you are interested in translating the manual the best way to
start is going to https://l10n.gnome.org/module/gimp-help/,
register an account and apply to be a member of the language team
for the language you want to translate.
You can then start translating the po files of GIMP's manual found
on that website.

### How to help writing the manual

If instead you would like to help out writing and improving the
manual then this is the right place to start.
Preferrably build the most up to date manual yourself or check
the latest uploaded version at https://docs.gimp.org/2.10/en/.

The source of the manual can be found in XML files in the /src
directory of this repository. Find a topic that interests you
or that needs updating and start writing.
You could also take a look at our issue tracker at
https://gitlab.gnome.org/GNOME/gimp-help/issues

It would be a good idea to subscribe to the gimp mailing lists,
especially the developer and docs lists. That way you can keep
up to date about the development of GIMP, see:
https://www.gimp.org/mail_lists.html
Most of the GIMP developers can also be reached on the #gimp
IRC channel on irc.gimp.org. The best chances to talk are
usually during European evening hours.

  ### What you should know

  You should know a bit about Docbook and XML, or be smart enough to learn
  the syntax yourself. You can get more information about Docbook and XML
  by using your preferred search engine.

  ### Editors, Programs and Setups

  Use any editor you want, but you should handle it well. Please keep in
  mind, that the tab width in XML Mode should be 2 spaces. It is
  recommended to attach patches to a bug report. Creating patches with
  git is probably better described at https://wiki.gnome.org, but in
  short:

    git format-patch HEAD^

  to create a patch with your last local commits.

  Provided you have xmllint installed, you can validate the XML
  and check the well-formedness of the XML files by running

    make validate

  When you edit an XML file and want to quickly check your changes,
  you can create a single quick-and-dirty HMTL draft file with

    make src/of/the/xml-file.draft

  where the target is the path name with extension ".draft" instead
  of ".xml", or with

    make preview-src/of/the/xml-file.xml

  where the path name is preceded with "preview-".

  The name of the HMTL draft file depends on its id (not on the name
  of the XML source file!) and is displayed when the file is created.


###  Hints for making good screenshots

  * please make screenshots only with the system default theme, which
    is of course just the plain gtk+ default look
  * use default fonts like Bitstream Vera Sans
  * crop the window manager borders
  * before saving an image as PNG, check if you can convert it to indexed
    mode without loss of quality (saves space and bandwidth)
  * provide your source images (eg. for making new screenshots in other
    languages)


## Documentation issues

See our Gnome Gitlab issue tracker:

  https://gitlab.gnome.org/GNOME/gimp-help/issues


## Creating a Release

**Note:** this section needs to be updated.

Before you create a release you'll need:

    * be a maintainer
    * have ssh access to pentagon.gimp.org
    * have access to http://www.gimp.org/admin/

### Steps

* Make sure that all XML is valid. Run:

    make validate-all

* Prepare the NEWS file, by adding an additional release, bugs fixed and
  contributors. You can use a little shortcut for compiling the
  contributors using git shortlog (<release tag> is the tag of the last
  release):

    git shortlog -sn <release tag>..HEAD


* Check if the authors.xml have to be adjusted for this release. (Not
  needed for every minor release).

* Bump the version number (help_(major, minor, micro)_version) in
  configure.ac, commit, push. Rule of thumb: It should be documented the
  current GIMP stable release. The minor version aligns therefore with
  the current stable release.

    vi configure.ac

* Create a distribution package:

    make dist

* Tag the release:

    git tag -s

  Rule of thumb: Use capital case, whitespace delimited by underscores.

* Copy the *.bz2 on to pentagon.gimp.org:/srv/ftp/pub/gimp/help/:

    scp gimp-help-*.tar.* pentagon.gimp.org:/srv/ftp/pub/gimp/help/

  Verify the tarball appears on:

    http://download.gimp.org/pub/gimp/help/

* Announce the release on http://www.gimp.org/admin/. Click on `Pending
  News` → `New News`, fill in the form (subject, announce), choose a
  reading wilber and press `Save`. Depending if it needs review (ask one
  of the developers), approve it to publish it.

* Announce the release on our mailing lists:

    GIMP Developer
    https://mail.gnome.org/mailman/listinfo/gimp-developer-list

    GIMP User
    https://mail.gnome.org/mailman/listinfo/gimp-user-list

    GIMP Docs
    https://mail.gnome.org/mailman/listinfo/gimp-docs-list

  Template:

      GIMP Manual <version> released

      We've released a new version of the user manual with:

        * <Changelog here>

      Download the packages from our download software.

    For easy installation we suggest that you wait until an installer for this
    release has been packaged for your platform. Find more releases and information
    about our goals and how you can help at https://docs.gimp.org.


## Updating supported languages

When adding a new language for translation several files need to be
updated. It's the intention to simplify this, but for now the list
of languages needs to be updated in the following files:

  - [configure.ac](configure.ac)
    - Update ALL_LINGUAS and QUICKREFERENCE_ALL_LINGUAS
  - [Makefile.GNU](Makefile.GNU)
    - Update ALL_LINGUAS
  - [quickreference/makefile.am](quickreference/makefile.am)
    - Update ALL_LINGUAS and QUICKREFERENCE_ALL_LINGUAS
  - [stylesheets/languageVocab.xml](stylesheets/languageVocab.xml)
    - Update vocab
  - [tools/get_po_status.pl](tools/get_po_status.pl)
    - Update my %Languages


## ODF Files

**Note:** this section needs to be updated and info about creating PDF files
should probably be added too.

You need docbook2odf installed to create ODF files. Although the
transformation process is very slow (because every picture is copied to
a temp directory), you can start the transformation by typing:

    make odf

Hint: Set the ALL_LINGUAS environment variable to create ODF files only
for a particular language.
Docbook2ODF can be obtained from the following website:

    http://open.comsultia.com/docbook2odf/

HINT: If you get an error opening the created ODT files, open
docbook2odf (probably installed in /usr/bin/) in a text editor.
Uncomment the line:

    #use encoding 'utf-8';

and rerun 'make odf'.


## History of the gimp-help module

The development on the original gimp-help modules came pretty much to a
stop after the first few stable versions of GIMP 1.2 were released. This is
due to several reasons, one of them being that all of the original
documentation had been converted from HTML to DocBook/SGML and apart from a
bit new content, lots of markup and proofreading not too much happened to
the organization of the complete mess.

Daniel Egger and Mel Boyce were not too happy about the quirks with
this help system. So they started completely from scratch creating a new
manual based on Docbook/XML called gimp-help-2.

Later this was renamed to gimp-help.
