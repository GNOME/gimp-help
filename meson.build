project('gimp-help',
    version: '3.1.1',
    meson_version: '>= 1.10.0',
)

gimp_help_version = '3.1.1'
src_dir = 'src'
po_dir  = 'po'

# FIXME update readme regarding adding translations after merging meson...
# GIMP_HELP_LINGUAS = \
#   ['bg', 'ca', 'cs', 'da', 'de', 'el', 'en', 'en_GB', 'eo', 'es', 'fa', 'fi',
#    'fr', 'hr', 'hu', 'it', 'ja', 'ko', 'lt', 'nl', 'nn', 'pt', 'pt_BR', 'ro',
#    'ru', 'sk', 'sl', 'sr', 'sv', 'tr', 'uk', 'zh_CN',]

#MY_LINGUAS = ['en', 'de', 'nl'] # FIXME Make this a meson option
MY_LINGUAS = []


SUBDIRS = 'quickreference'

## Imports
fs = import('fs')

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
# Define xml2po related stuff

MSGWIDTH = 79

XML2PO        = find_program(meson.project_source_root() / 'tools' / 'xml2po.py')
#XML2POFLAGS  = '-k --mode=gimphelp'

#MSGUNIQ = /mingw64/bin/msguniq
MSGUNIQ       = find_program('msguniq')
MSGUNIQFLAGS  = ''

MSGCAT        = find_program('msgcat')
MSGCATFLAGS   = '--width=@0@'.format(MSGWIDTH)

MSGFMT        = find_program('msgfmt')
MSGFMTFLAGS   = '--check --use-fuzzy --statistics'

MSGINIT       = find_program('msginit')
MSGINITFLAGS  = '--no-translator --width=@0@'.format(MSGWIDTH)

MSGMERGE      = find_program('msgmerge')
MSGMERGEFLAGS = '--quiet --width=@0@'.format(MSGWIDTH)


xml2pot      = find_program(meson.project_source_root() / 'tools' / 'xml2pot.sh')
xml2po       = find_program(meson.project_source_root() / 'tools' / 'xml2po.py')
updatepo     = find_program(meson.project_source_root() / 'tools' / 'update_po.py')

# Image handling, needs perl until we are able to convert it
copy_images      = find_program(meson.project_source_root() / 'tools' / 'copy_images.sh')
perl             = find_program('perl')
MAKE_IMAGE_LINKS = find_program(meson.project_source_root() / 'make.d' / 'make_image_links.pl')
MAKE_IMAGE_LINKS_FLAGS = '-v'

if platform_windows
    MAKE_IMAGE_LINKS_FLAGS += '-m=hardlink,copy'
endif

# FIXME: Don't depend on sh, use Python?
cp           = find_program('cp')
ln           = find_program('ln')
dummy_ls     = find_program('ls')

message('@0@'.format(XML2PO.full_path()))
#message(MSGUNIQ)

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

################################################################################
# Get Meson modules

#pkgconfig = import('pkgconfig')
#i18n      = import('i18n')
#gnome     = import('gnome')
pythonmod = import('python')

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


###############################################################################
# Configuration

#python3 = import('python3')
#conf = configuration_data()
#conf.set('PYTHON', python.full_path())
#conf.set('top_srcdir', meson.project_source_root())
#conf.set('gimpdir', '~/gimp-2.10')

top_srcdir = meson.project_source_root()
# FIXME gimp_dir needs to be user configurable...
gimp_dir   = '~/gimp'

message(top_srcdir)


#gimpdir = get_option('gimpdir')
#if gimpdir == ''
  # Default value
#  gimpdir = '../../gimp-2.10'
#endif

help_src_dir = meson.project_name() / src_dir
help_po_dir  = meson.project_name() / po_dir
#gimpdatadir    = get_option('datadir')    / project_subdir
#gimpplugindir  = get_option('libdir')     / project_subdir
#gimpsysconfdir = get_option('sysconfdir') / project_subdir
#gimpmanpagedir = gimpdir
#localedir      = get_option('datadir') / 'locale'

message('Project source dir: ' + help_src_dir)
message('Project locale dir: ' + help_po_dir)


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


custom_target('validate-references',
  input : [ ],
  output: [ 'validate-references', ],
  command: [
    find_program(meson.project_source_root() / 'tools' / 'validate_references.py'),
    meson.project_source_root(),
  ],
  build_by_default: false,
)


########################################################################
####            The GIMP manual languages                           ####
########################################################################

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

# if MY_LINGUAS.length() == 0
#   MY_LINGUAS = LINGUAS
# endif

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
  message('No languages selected or error in configuration')
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
# Trying to circumvent that by exiting /src early the first time does not
# work: ERROR: Tried to enter directory "src", which has already been visited.
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
####            Make pot files:  XML(en) --> POT                    ####
########################################################################


#xml2po_env = environment()
#xml2po_env.append('XML2PO',  XML2PO.full_path())
#xml2po_env.append('MSGUNIQ', MSGUNIQ.full_path())

# # Make pot directory if not existing
# run_command (
#     'mkdir', '-p', meson.project_build_root() + '/pot',
#     check: false
# )
# # Make xml directory if not existing
# run_command (
#     'mkdir', '-p', meson.project_build_root() + '/xml',
#     check: false
# )
# # Make html directory if not existing
# run_command (
#     'mkdir', '-p', meson.project_build_root() + '/html',
#     check: false
# )

# Seems currently these subdir pot targets always get built if
# I add: build_by_default: true
# However, if I don't add that, they do not get built at all
# Probably because of the differing output directories from
# the sources (pot versus src) it doesn't pick up that things
# have changed and need to be rebuilt.
# I do not know enough about meson to figure out how to fix
# this, ideas are welcome
# Maybe it could work if the meson.build files were located
# in pot/ directories in the source instead of inside src/
# since currently meson is also adding subdirs under src
# where we have meson.build files.

# --> Looks like you have to do it like explained in the
#     files() command.

pot_base = 'pot/'

# Documentation source files
subdir('src')

# pot needs generated authors.xml in src/preface
subdir('pot')

# Generate updated po files in build dir
# FIXME May need discussion with DamnedLies if they can grab the updated
#       po files from the build dir!
subdir('po')

# Generate translated xml files...
subdir('images')
subdir('html')

xml2pot_targets = []

# foreach pot_action : pot_list
#   xmlsubdir = pot_action.get('dir')
#   srcdir    = 'src/'+ xmlsubdir + '/'
#   targetdir = 'pot/'
#   srcfiles  = []
#   foreach srcfile : pot_action.get('files')
#     srcfiles += srcdir + srcfile
#   endforeach

#   #message('Creating target for ' + pot_action.get('target'))

# #   xml2pot_target = custom_target(pot_action.get('target'),
# #     input: srcfiles,
# #     output: [pot_action.get('target')],
# #     command: [
# # #      xml2pot, pot_action.get('target'), srcfiles,
# #       xml2pot, '@OUTPUT@', '@INPUT@',
# #     ],
# #     build_by_default: true,
# #   )
#   # xml2pot_target = run_target(pot_action.get('target'),
#   #   command: [
#   #     xml2pot, [pot_action.get('target')], srcfiles,
#   #   ],
#   #   # apparently env was only added in meson 0.57 while we are using 0.55...
#   #   #env: xml2po_env,
#   #   # env: {
#   #   #   'XML2PO' : XML2PO.full_path(),
#   #   #   'MSGUNIQ': MSGUNIQ.full_path(),
#   #   # }
#   #   # env: [
#   #   #   'XML2PO=test/',
#   #   #   'MSGUNIQ=msguniq',
#   #   # ]
#   # )
# #  xml2pot_targets += pot_action.get('target') #xml2pot_target
# #  xml2pot_targets += xml2pot_target

# #   xml2pot_target = custom_target('xml2pot-' + xmlsubdir,
# #     input: srcfiles,
# # #    output: ['xml2pot-' + xmlsubdir],
# #     output: [pot_action.get('target')],
# #     command: [
# #       xml2pot, '@OUTPUT@', '@INPUT@',
# # #      XML2PO, XML2POFLAGS, '--output=-',
# # #      '@INPUT@',
# #     #capture: [xml2po_result]
# #     ]
# #   )
# #   # msg_uniq = run_command(
# #   #   MSGUNIQ, MSGUNIQFLAGS
# #   # )
# endforeach

# )

if xmllint.found()
  run_target('validate-authors',
    command: [
      xmllint,
      '--noout',
      '--valid', 'authors.xml',
    ],
  )
endif

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

# lang='nl'
# po_input = ['po/nl/gimp.po']
# xml_input = ['src/gimp.xml']

# gen = generator(
#   po2xml_cmd,
#   output: [
#     'xml/'+lang+'/'+'@BASENAME@.xml',
#   ],
#   arguments: [
#     '--po-file=' + '@INPUT@',
#     '--language=' + lang,
#     'output=@OUTPUT@',
#     xml_input,
#   ],
# )

# gen_xml = gen.process([ 'bugs' ])
