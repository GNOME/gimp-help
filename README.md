# GIMP-Help

GIMP-Help is a help system designed to display GIMP's User Manual using
a browser or HTML renderers.  
Our documentation is written in [DocBook XML](https://docbook.org/), which
allows us to create a highly customizable documentation system.

The current user manual documents version 3.0 of GIMP.  
The manual for GIMP 2.10 is not being maintained anymore, but translations are
still accepted until the release of 3.0. It is available in a separate branch
called `gimp-help-2-10`.

## Contents

1. [Published manuals](#published-manuals)
2. [Tips for contribution](#tips-for-contribution)  
  2.1 [Translating](#how-to-help-translating-the-manual)  
  2.2 [Manual writing](#how-to-help-writing-the-manual)
3. [Documentation issues](#documentation-issues)
4. [Creating a Release](#creating-a-release)
5. [Updating supported languages](#updating-supported-languages)
6. [History of the gimp-help module](#history-of-the-gimp-help-module)


## Published manuals

The online, daily updated, manuals for all supported languages are available at:

- [GIMP 3.0 manuals](https://docs.gimp.org/index.html#gimp-online)
- [GIMP 2.10 manuals](https://docs.gimp.org/online.html#gimp210)

The offline manuals are available for download from [Releases page](https://docs.gimp.org/download.html).

## Tips for contribution

### How to help translating the manual

If you are interested in translating the manual the best way to
start is going to the [DamnedLies translation platform](https://l10n.gnome.org/).
Register an account there, if you don't have one yet, and apply to be a member
of the language team for the language you want to translate.  

All our translations are done through DamnedLies. To start translating the
manual go to the [translatable po files](https://l10n.gnome.org/module/gimp-help/)
for the manual. After you finish translating, you upload it to DamnedLies.
Your language team will be able to give you more details on this procedure.

**Note:** If your language does not have any po files listed there, your
language first needs to be added to our repository. In that case, please open
[an issue](https://gitlab.gnome.org/GNOME/gimp-help/issues) stating which
language and languagecode you would like to have added.

#### How to test your translation

If you have set up a build environment for gimp-help you can test the
translation by running `make html-LANG`, where LANG is your two/four-letter
language code. This will generate an HTML version of the user manual,
e.g. `make html-nl` to make the HTML for the Dutch language.
When that is successful, you can find the index.html file in the `/html/LANG/`
folder under your gimp-help build folder.

#### How to add localized screenshots

Localized images also need to be reviewed first by your language team through
DamnedLies. Discuss with your language team how to do that, after review
they need to be committed to the gimp-help repository by opening a
Merge Request (MR).
Either your language team leader opens the MR with the localized images, or
at the very least the team leader needs to comment on the MR that
the changes are vetted and reviewed by your team.

All images are stored in the top-level 'images' folder. Original
screenshots in English are in the 'C' subfolder. Localized screenshots
are in 'LANG' folders, where LANG is your two/four-letter language code.

It is important to preserve both paths and names when saving localized
versions of the screenshots. Otherwise documentation won't build properly,
or the localized images will not be used.

More in general, also follow the relevant [guidelines](documentation-guidelines.md)
regarding image handling.

### How to help writing the manual

If instead you would like to help out writing and improving the
manual then this is the right place to start.

First, it would be a good idea to subscribe to messages that have the GIMP or
documentation tags on [Gnome's Discourse server](https://discourse.gnome.org/).
Note: when asking a question on Discourse make sure you add tags for GIMP
and documentation (or i18n if it is related to translations), or we may
not see your message.

Most of the GIMP developers can also be reached on the #gimp
IRC channel on irc.gimp.org. The best chances to talk are
usually during European evening hours.

If some of the instructions below are unclear, don't hesitate
to ask in one of the places mentioned above.

To get started, here is a checklist of things you should do:
- If you don't have a Gnome GitLab account yet then create one
  (you can use GitHub credentials to login), see:
  https://gitlab.gnome.org/
- Next go to https://gitlab.gnome.org/GNOME/gimp-help and
  create your own fork by clicking on "Fork" on the top
  right of the page.
- Go to your fork at https://gitlab.gnome.org/YOUR_USERNAME/gimp-help
- gimp-help uses a CI pipeline to validate the contents of the repo at each
  commit. Make sure to setup the CI settings for your fork correctly:
  + `Settings > General > Visibility`:
    - Set `Project visibility` to `Public`
    - Enable `Repository` with `Everyone With Access`
    - Enable `CI/CD` with `Everyone With Access`
    - Enable `Container registry` (any visibility level)
  + `Settings > CI/CD > General pipelines`:
    - Enable `Public pipelines`
- Make sure to read our [documentation guidelines](documentation-guidelines.md),
  which includes the [style guide](documentation-guidelines.md#style-guide).
- For relatively small and simple edits you can use the web-ide
  if you don't want to set up a build environment on your computer.
  + In the left-hand menu, expand the `Code` section, and then select
    `Repository`.
  + From the `+` list at the top of the page, select `New branch`, and then
    create a new branch from `master` for your updates.
  + Back on the Repository page, from the `Edit` menu, select `Web IDE`.
  + In the web IDE, use the file explorer on the left-hand side to navigate to
    the `/src/` folder, and then select the file you want to update.
  + Make the required changes.
  + From the menu of icons on the left-hand side of the page, select
    `Source Control`.
  + In the `Commit message` field, enter a brief description of your changes.
  + Above the `Commit message` field, select the tick icon to commit your
    changes.
  + Make sure the CI pipeline succeeds. Otherwise, inspect the pipeline for the
    cause of failure and fix it. To view the status of the CI pipeline, select,
    `Build > Pipelines`.
  + Next you need to create a Merge Request (MR) for the commit.
  + This MR will show up in the main gimp-help repository and
    will be reviewed and evaluated.
- For more complicated edits, reordering parts of the help,
  or adding screenshots, you should clone the repository to
  your computer and work on it locally.
  + On your fork of gimp-help, click the blue `Code` button
    and choose your preferred method to clone the repository.
  + In case you are on Windows, it is strongly advised to
    set up a MSYS2 environment, so that you can build and
    test the gimp-help repository. MSYS2 includes multiple environments, each
    of which is accessed through its own executable. It is advised that you use
    UCRT64 or CLANG64. For more information, refer to
    [Environments](https://www.msys2.org/docs/environments/) in the MSYS2
    documentation.
  + TODO: Other OS's may need some setting up too. Add
    details here as needed.
  + You need the following packages to build the documentation:
    + Minimum: autotools, libxslt, python, libxml2-python,
      docbook-xml, and docbook-xsl. With these packages, you can build the
      English html help.
    + Version control: git.
    + To build quick start PDFs: librsvg2-2. For some laguages, you may also
      need to install the appropriate [Noto fonts](https://fonts.google.com/noto). 
      For more information, refer to
      [#410](https://gitlab.gnome.org/GNOME/gimp-help/-/issues/410)
      To install librsvg2-2 for MSYS2, refer to 
      [Base Package: mingw-w64-librsvg](https://packages.msys2.org/base/mingw-w64-librsvg)
      for information about what package to install. You can use `make pdf` to
      build quick start PDFs for all languages. 
    + TODO: Test and confirm requirements to work with localized versions.
      Assumed gettext as a minimum. Also polib for the validation of po files.
      To install polib, use a package manager (e.g., pacman) to install pip,
      and then use pip to install polib. gettext may already be installed in
      an MSYS2 environment.
    + To build the installers: intltool and innosetup.
    + To create an architecture diagram of the build process: dot, which is
      part of graphviz. For MSYS2, refer to
      [Base Package: mingw-w64-graphviz](https://packages.msys2.org/base/mingw-w64-graphviz)
      for information about what package to install. To generate the diagram,
      use `make dot`.
    + To build PDF versions of the help: dblatex. Note that PDF versions of
      help are no longer being created because dblatex doesn't seem to be
      compatible with more recent versions of Python. Refer to
      [#138](https://gitlab.gnome.org/GNOME/gimp-help/-/issues/138) for more
      information. When everything is set up correctly, use `make pdf-xx` to
      build a PDF for a single language or `make pdf-local` to build PDFs for
      all languages.
      + TODO: Test and confirm the process to install dblatex. For more
        information, refer to the
        [dblatex SourceForce site](https://dblatex.sourceforge.net/).
    + Note: the autogen script also checks if pngnq and pngcrush are
      installed, but they are not used.
  + Assuming you have cloned the git repo on your computer,
    make a build dir inside or outside your tree depending
    on your personal preference, then run from the build dir:
    `../autogen.sh --prefix=${INSTALL_PREFIX} --without-gimp`.
    + Note: If you want to build help for only a specific subset of supported
      languages, add `ALL_LINGUAS="en xx"`; where the value in quotes is a
      space separated list of language codes. Then, when you use a `make`
      command without specifying a language, such as `make html` instead of
      `make html-en`, you will build outputs for only your chosen languages.
    + Note: You can rerun the autogen script to rebuild the make files. For
      example, if you want to change which languages you build help for, or
      you install a new package.
  + TODO: On Windows you may have to add `--build=mingw64`,
    possibly also `DESTDIR=$BUILD_DIR $SRCDIR`.
  + After running autogen once, you can use the following
    command repeatedly for making the English manual:
    `make html-en`.
  + You can check the output in your build dir in the
    /html/en/ folder.
  + If that is working, select a file from the /src/
    folder that you want to work on and start editing.
  + When finished with a set of related edits, you
    should first validate your changes to check that
    you didn't make any mistakes in the docbook XML
    format. The command for this is `make validate-en`.
  + If everything is fine commit your changes with a
    descriptive commit message. Make sure you always do
    related changes in a separate branch.
  + Push your changes to your fork on Gnome GitLab.
  + Make sure the CI pipeline succeeds. Otherwise, inspect the pipeline for the
    cause of failure and fix it.
  + Go to your online fork and click the Merge Request
    button.
- Make sure that you have notifications enabled, because you
  may be asked to change certain things, or need to explain
  why you made certain changes.
- Don't expect a reply immediately. There is only a small
  team working on this. A review can sometimes take weeks or
  even months, although we try to get back to you sooner.
- Some additional info can also be read in the manual, see
  https://docs.gimp.org/3.0/en/gimp-contributing.html
  (although some parts there need to be revised).

TODO
- Mention that make sometimes causes certain po translations
  to get updated. They should not be committed together with
  source documentation changes.
- It may be useful to document the use of virtual environments for python
  (i.e., [venv](https://docs.python.org/3/library/venv.html)). With MSYS2,
  a user may encounter an externally-managed-environment error when they
  attempt to install python packages through pip. 

Preferably build the most up to date manual yourself or check
the latest uploaded version at https://docs.gimp.org/3.0/en/.

The source of the manual can be found in XML files in the /src
directory of this repository. Find a topic that interests you
or that needs updating and start writing.

You could also take a look at our issue tracker at
https://gitlab.gnome.org/GNOME/gimp-help/issues

  ### What you should know

  You should know a bit about Docbook and XML, or be smart enough to learn
  the syntax yourself. You can get more information about Docbook and XML
  by using your preferred search engine.
  Also make sure you read our [documentation guidelines](documentation-guidelines.md).

  ### Editors, Programs and Setups

  Use any editor that supports editing XML. Please keep in mind, that the
  tab width in XML Mode should be 2 spaces.

  Provided you have xmllint installed, you can validate the XML
  and check the well-formedness of the XML files by running

    make validate-en

  Running `make validate` is also possible, but validating for all
  languages takes considerable time.
  Translators are encouraged to validate their language by replacing
  `en` above with their language code.

  When you edit an XML file and want to quickly check your changes,
  you can create a single quick-and-dirty HTML draft file with

    make src/of/the/xml-file.draft

  where the target is the path name with extension ".draft" instead
  of ".xml", or with

    make preview-src/of/the/xml-file.xml

  where the path name is preceded with "preview-".

  The name of the HTML draft file depends on its id (not on the name
  of the XML source file!) and is displayed when the file is created.


###  Hints for making good screenshots

  * Please make screenshots only with the system default theme, which
    is of course just the plain gtk+ default look - FIXME Nowadays
    dark mode is often used. Using a dark theme is totally ok to me.
    If we want a unified look that would mean creating all images
    on one platform with one chosen theme. At this moment that doesn't
    seem feasible.
  * Use default fonts like Bitstream Vera Sans - FIXME This is not a
    crossplatform default font, we need a better suggestion.
  * Crop the window manager borders; or even more if the image is intended
    to only show a limited set of things that need an explanation.
  * Before saving an image as PNG, check if you can convert it to indexed
    mode without loss of quality (saves space and bandwidth) FIXME:
    see pngnq that does that for you including reducing size, but beware
    for small images size may increase. This also only works well with
    screenshots that do not show any photos or similar. You have to check
    first if the resulting image does not differ too much from the original.
    Maybe tell not to add metadata unless needed, no comment, no thumbnail,
    maybe also no color profile or is it better to have that included.
  * TODO Add info about the different pngcrush programs
    pngnq in my tests is often the smallest (default settings), but check
    if the result isn't too different from the original.
  * Provide your source images (eg. for making new screenshots in other
    languages) - add info where in the source tree they should be added,
    info to keep xcf size as small as possible, small image dimensions
    where possible (64 x 64?) - set "use better but slower compression"
    when saving to xcf; for most example imagess using 8 bit integer precision
    is enough, unless specifically demonstrating higher bit depth.


## Documentation issues

See our Gnome Gitlab issue tracker:

  https://gitlab.gnome.org/GNOME/gimp-help/issues


## Creating a Release

**Note:** this section needs to be updated.

**Note2:** For make dist and make dist-check automake 1.16.4 or newer is
required. Older versions will not recognize README.md as a valid version
instead of README.

Before you create a release you'll need:

    * be a maintainer
    * have ssh access to pentagon.gimp.org
    * have access to http://www.gimp.org/admin/
    * FIXME: Check if this is still up-to-date.

### Steps

* Make sure that all XML is valid. Run:

    make validate-all

* Prepare the NEWS file, by adding an additional release, bugs fixed and
  contributors. You can use a little shortcut for compiling the
  contributors using git shortlog (<release tag> is the tag of the last
  release):

    git shortlog -sn <release tag>..HEAD

* Note: the above is not always complete for translators since most
  translations are committed by language team coordinators, not necessarily
  the persons that did the actual translation.

* Check if the authors.xml have to be adjusted for this release.

* Bump the version number (help_(major, minor, micro)_version) in
  configure.ac, commit, push. Rule of thumb: It should document the
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

* Add the Windows installers

* Update our websites: docs.gimp.org and gimp.org/docs

* Announce the release on http://www.gimp.org/admin/. Click on `Pending
  News` → `New News`, fill in the form (subject, announce), choose a
  reading wilber and press `Save`. Depending if it needs review (ask one
  of the developers), approve it to publish it.

* Announce the release on Discourse using gimp and documentation tags:

    Discourse
    https://discourse.gnome.org/

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
    - Update ALL_LINGUAS
  - [Makefile.GNU](Makefile.GNU)
    - Update ALL_LINGUAS
  - [stylesheets/languageVocab.xml](stylesheets/languageVocab.xml)
    - Update vocab
  - [stylesheets/authors_common.xsl](stylesheets/authors_common.xsl)
    - Update `<xsl:variable name="languages">`
  - [tools/get_po_status.pl](tools/get_po_status.pl)
    - Update my %Languages
  - [web/website.xml](web/website.xml)
    - Update list of online user manuals and quickreference PDF's
  - [.gitlab-ci.yml](.gitlab-ci.yml)
    - Update LINGUAS in the relevant build-debian-[number].
    - Update LINGUAS in the relevant distcheck-[number].
    - Note: after committing make sure that the build job doesn't take too
      long. When it takes more than 50 minutes, it might be time to split
      the build job because we don't want time-outs.
  - [build/windows/installer/installer-gimp-help-msys2.sh](build/windows/installer/installer-gimp-help-msys2.sh)
    - Check if the language is part of the official languages installed
      together with Inno Setup. An up-to-date list can be found at
      [github](https://github.com/jrsoftware/issrc/tree/main/Files/Languages).
    - If not, check if there is an unofficial translation,
      [here](https://github.com/jrsoftware/issrc/tree/main/Files/Languages/Unofficial).
    - If there is, then add it to the download_lang commands.
    - If no translation is available `Default.isl` can be used.
  - [build/windows/installer/gimp-help.iss](build/windows/installer/gimp-help.iss)
    - Add a if LANG test and define LANGFILE for you language.

Note: If your build directory is not a child of the source directory, then
`msginit` will not fill in PACKAGE_VERSION in the header of the po files.  
Since msginit tries to find `configure`, copying that to your build directory
can solve that issue. In that case, make sure to update it when switching
branches.

When all of the above are updated, run:
  - `make po` in the main build directory
  - `make po` in the quickreference directory
  - `make update-po` in the po-windows-installer directory (make sure that
    charset is UTF-8 here, it wasn't for me, need to check this sometime)

This should create the necessary po files for the newly added language.  
Note: some po files for other languages may have been updated too, but you
should only commit the files relevant for the new language.


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
