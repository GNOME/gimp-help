project('gimp-help',
    version: '3.1.1',
    meson_version: '>= 1.10.0',
)

gimp_help_version = '3.1.1'


################################################################################
# Host system detection

host_os = host_machine.system().to_lower()

platform_linux = (
  host_os.contains('linux')
)

platform_windows = (
  host_os.contains('mingw') or
  host_os.contains('cygwin') or
  host_os.contains('windows')
)

platform_osx = (
  host_os.contains('machten') or
  host_os.contains('rhapsody') or
  host_os.contains('darwin')
)

################################################################################
# Get Meson modules

pythonmod = import('python')
fs        = import('fs')

###############################################################################
# Check for python...

python3_minver = '>=3.6'

python = pythonmod.find_installation('python3', required: true)
message('Found Python @0@'.format(python.language_version()))

python_found = (
  python.found() and
  python.language_version().version_compare(python3_minver)
)
if not python_found
  python_warning = '''
  Python @0@ was not found or version was too old.
  '''.format(python3_minver)
  warning(python_warning)
  warnings += python_warning
endif

########################################################################
####            External programs                                   ####
########################################################################

# Check for XML tools
if platform_windows
  # The /usr/bin/ version usually has less issues on Windows because it
  # uses the Linux paths IIRC
  #TODO: find location of MSYS2 instead of hardcoding!!!
  # Maybe find a program that only exists in msys2 and use that location?
  xmllint  = find_program('xmllint', required: false, dirs: ['c:/msys64/usr/bin/'])
  xsltproc = find_program('xsltproc', dirs: ['c:/msys64/usr/bin/'])
else
  xmllint  = find_program('xmllint', required: false)
  xsltproc = find_program('xsltproc')
endif

# Check for gettext tools
#FIXME For now width is hardcoded in our tools
#MSGWIDTH      = 79

MSGUNIQ    = find_program('msguniq')

MSGCAT     = find_program('msgcat')

MSGFMT     = find_program('msgfmt')

MSGINIT    = find_program('msginit')

MSGMERGE   = find_program('msgmerge')

# Check other external tools
perl       = find_program('perl')   # image handling

# Shell tools
# FIXME: Don't depend on sh, use Python?
cp         = find_program('cp')
ln         = find_program('ln')

################################################################################
# Internal tools

# Define xml2po related stuff
XML2PO        = find_program(meson.project_source_root() / 'tools' / 'xml2po.py')

xml2pot      = find_program(meson.project_source_root() / 'tools' / 'xml2pot.sh')
xml2po       = find_program(meson.project_source_root() / 'tools' / 'xml2po.py')
updatepo     = find_program(meson.project_source_root() / 'tools' / 'update_po.py')

# Image handling, needs perl until we are able to convert it
copy_images      = find_program(meson.project_source_root() / 'tools' / 'copy_images.sh')
MAKE_IMAGE_LINKS = find_program(meson.project_source_root() / 'make.d' / 'make_image_links.pl')
MAKE_IMAGE_LINKS_FLAGS = '-v'

if platform_windows
    MAKE_IMAGE_LINKS_FLAGS += '-m=hardlink,copy'
endif

################################################################################
# Define authors and maintainers sources

# list of authors and contributors (no DocBook)
AUTHORS_DATA_XML = ['stylesheets/authors.xml']

# automatically generated authors section (DocBook)
##AUTHORS_DOCBOOK_XML = 'src/preface/authors.xml'
AUTHORS_DOCBOOK_XML = 'authors.xml'
#AUTHORS_DOCBOOK_DIRNAME = $(dir $(AUTHORS_DOCBOOK_XML))
#AUTHORS_DOCBOOK_FILENAME = $(notdir $(AUTHORS_DOCBOOK_XML))

# Stylesheets generating AUTHORS
AUTHORS_TEXT_STYLESHEETS = \
  ['stylesheets/authors_text.xsl',
  'stylesheets/authors_common.xsl',]

# Stylesheets generating src/preface/authors.xml
AUTHORS_DOCBOOK_STYLESHEETS = \
  ['stylesheets/authors_docbook.xsl',
  'stylesheets/authors_common.xsl']

AUTHORS_TEXT    = AUTHORS_TEXT_STYLESHEETS + AUTHORS_DATA_XML
AUTHORS_DOCBOOK = AUTHORS_DOCBOOK_STYLESHEETS + AUTHORS_DATA_XML

# Stylesheet generating MAINTAINERS
DOAP_STYLESHEET = ['stylesheets/doap2text.xsl']

# Maintainers doap
MAINTAINERS_DOAP = ['gimp-help.doap']

MAINTAINERS_TEXT = DOAP_STYLESHEET + MAINTAINERS_DOAP


# used for creating the ChangeLog
LAST_RELEASE_TAG = 'GIMP_HELP_3_0_0'

warnings = ''


###############################################################################
# Configuration




########################################################################
####            The GIMP manual languages                           ####
########################################################################

# FIXME update readme regarding adding translations after merging meson...

LINGUAS  = ['en']
LINGUAS += fs.read('./po/LINGUAS').strip().split('\n')

selected_languages = get_option('languages')

if selected_languages.startswith('all')
  MY_LINGUAS = LINGUAS
elif selected_languages.startswith('none') or selected_languages == ''
  MY_LINGUAS = 'en'
else
  MY_LINGUAS = selected_languages.strip().split(' ')
endif

message('Selected languages: ', MY_LINGUAS)

# ALL_LINGUAS is required in /stylesheets/, which is why we handle reading LINGUAS here
target_linguas = []
ALL_LINGUAS = ''
foreach lang : MY_LINGUAS
  if not lang.startswith('#')
    if not (lang in LINGUAS)
      if not lang.startswith('#')
          lang_warning = 'Language "@0@" not found in all_linguas!'.format(lang)
          warning(lang_warning)
          warnings += lang_warning
      endif
    else
      target_linguas += lang
      ALL_LINGUAS += lang
    endif
  endif
endforeach

if ALL_LINGUAS == ''
  error('No languages selected or error in configuration')
  subdir_done()
endif


#### Build/copy stylesheets ####

# Stylesheets needs to be done first: it is required to generate authors and
# maintainers files.
subdir('stylesheets')

########################################################################
####            Make AUTHORS and MAINTAINERS file                   ####
########################################################################

ss_path = meson.project_build_root()  + '/stylesheets/'

authors_file = custom_target('AUTHORS',
  #input : [authors_text_ss.full_path(), authors_data.full_path()],
  depend_files: [authors_text_ss, authors_data],
  output: 'AUTHORS',
  command: [
    xsltproc,
    '--verbose',
    '-o', '@OUTPUT@',
    ss_path + AUTHORS_TEXT_STYLESHEETS,
    ss_path + AUTHORS_DATA_XML
  ],
  build_by_default: true,
)

# We have a circular dependency: src/preface/authors.xml needs to be created
# and moved to src first, so we need to be in /src first. However, before
# we can make translated xml (based on the files in /src), we need pot files
# created first, for which /pot needs to be entered first.
# So, we have no other choice than generating authors.xml first without
# going to /src/preface first.

authors_file_xml = 'authors.xml'
authors_subdir   = '/src/preface/'

preface_authors_xml = custom_target('preface-authors-xml',
    #depends: [authors_file],
    input: [authors_docbook_ss, authors_data],
    output: authors_file_xml,
    command: [
        xsltproc,
        '-o', meson.current_build_dir() + '/authors.xml',
        '@INPUT@',
    ],
    #build_by_default: true,
)

copy_authors_to_src = custom_target('copy-to-src-authors',
    input: preface_authors_xml,
    output: ['authors-copy-to-source.xml'],
    command: [
        'cp',
        # Special case here since authors.xml is only available
        # in the build dir!
        meson.project_build_root()  + '/' + authors_file_xml,
        meson.project_source_root() + authors_subdir + authors_file_xml,
    ],
    build_by_default: true,
)


# Maintainers doap resides in the root
MAINTAINERS_DOAP       = ['gimp-help.doap']
MAINTAINERS_STYLESHEET = ['stylesheets/doap2text.xsl']

MAINTAINERS_TEXT = MAINTAINERS_STYLESHEET + MAINTAINERS_DOAP

maintainers_file = custom_target('MAINTAINERS',
  input : MAINTAINERS_TEXT,
  output: 'MAINTAINERS',
  command: [
    xsltproc,
    '-o', '@OUTPUT@',
    '@INPUT@',
  ],
  build_by_default: true,
)


########################################################################

#xml2po_env = environment()
#xml2po_env.append('XML2PO',  XML2PO.full_path())
#xml2po_env.append('MSGUNIQ', MSGUNIQ.full_path())


# Documentation source files
subdir('src')

# Generate pot files, which needs generated authors.xml in src/preface, generated above
subdir('pot')

# Generate updated po files in build dir
# FIXME May need discussion with DamnedLies if they can grab the updated
#       po files from the build dir!
#       (I think that maybe they only need pot and generate po themselves; Check!)
subdir('po')

# Define English images
subdir('images')

# Copy images; generate translated xml files; then generate html etc...
subdir('html')


###############################################################################
### Quickreference ###

if get_option('quickreference')
  SVG2PDF = find_program('rsvg-convert')

  subdir('quickreference')
endif


###############################################################################
### Website ###
if get_option('maintainer')
  subdir('web')
endif


###############################################################################
# Validation / Testing

if xmllint.found()
  run_target('validate-authors',
    command: [
      xmllint,
      '--noout',
      '--valid', 'authors.xml',
    ],
  )
endif

# Should be run-target?
custom_target('validate-references',
  input : [ ],
  output: [ 'validate-references', ],
  command: [
    find_program(meson.project_source_root() / 'tools' / 'validate_references.py'),
    meson.project_source_root(),
  ],
  build_by_default: false,
)

###############################################################################
#custom_target('Changelog',
#  input : [ ],
#  output: [ 'Changelog', ],
#  command: [
#    generate_changelog,
#    meson.project_source_root(),
#    '@OUTPUT@'
#  ],
#  build_by_default: false,
#)
