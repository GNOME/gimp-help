project('gimp-help',
    version: '3.0.1',
    meson_version: '>= 1.4.0',
)

gimp_help_version = '3.0.1'
src_dir = 'src'
po_dir  = 'po'

# FIXME: List is incomplete!
GIMP_HELP_LINGUAS = \
  ['ca', 'da', 'de', 'el', 'en', 'en_GB', 'es', 'fi', 'fr', 'hr', 'it',
   'ja', 'ko', 'lt', 'nl', 'nn', 'pt_BR', 'ro', 'ru', 'sl', 'sv', 'zh_CN',]

ALL_LINGUAS = ''

#LINGUAS = ['en', 'nl', 'xy']
LINGUAS = ['en', 'nl']

SUBDIRS = 'quickreference'


################################################################################
# Define xml2po related stuff

MSGWIDTH = 79

XML2PO       = find_program(meson.project_source_root() / 'tools' / 'xml2po.py')
XML2POFLAGS  = '--mode=gimphelp'

#MSGUNIQ = /mingw64/bin/msguniq
MSGUNIQ      = find_program('msguniq')
MSGUNIQFLAGS = ''

MSGCAT       = find_program('msgcat')
MSGCATFLAGS  = '--width=@0@'.format(MSGWIDTH)

xml2pot      = find_program(meson.project_source_root() / 'tools' / 'xml2pot.sh')
xml2po       = find_program(meson.project_source_root() / 'tools' / 'xml2po.py')

cp           = find_program('cp')

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

########################################################################
####            The GIMP manual languages                           ####
########################################################################

all_linguas = ALL_LINGUAS
if all_linguas == ''
  all_linguas = GIMP_HELP_LINGUAS
endif

target_linguas = []
foreach lang : LINGUAS
  if not (lang in all_linguas)
    lang_warning = 'Language "@0@" not found in all_linguas!'.format(lang)
    warning(lang_warning)
    warnings += lang_warning
  else
    target_linguas += lang
  endif
endforeach

# if doc_linguas != ''
#   doc_linguas_warning = '''
#   Do not set the internal variable DOC_LINGUAS.
#   '''
#   warning(doc_linguas_warning)
#   warnings += doc_linguas_warning
# endif



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
xmllint             = find_program('xmllint', required: false)
xsltproc            = find_program('xsltproc')


custom_target('validate-references',
  input : [ ],
  output: [ 'validate-references', ],
  command: [
    find_program(meson.project_source_root() / 'tools' / 'validate_references.py'),
    meson.project_source_root(),
  ],
  build_by_default: false,
)

#### Build/copy stylesheets ####

# Stylesheets needs to be done first: it is required to generate authors and
# maintainers files.
subdir('stylesheets')

########################################################################
####            Make AUTHORS and MAINTAINERS file                   ####
########################################################################

# FIXME This needs to be changed before meson 2.0!
#../../gimp-help/meson.build:228: WARNING: Source item 'D:/msys64/home/Jacob/build-clang64/gimp-help-meson/stylesheets/authors_text.xsl' cannot be converted to File object,
#because it is a generated file. This will become a hard error in meson 2.0.
#../../gimp-help/meson.build:228: WARNING: Source item 'D:/msys64/home/Jacob/build-clang64/gimp-help-meson/stylesheets/authors.xml' cannot be converted to File object, becau
#se it is a generated file. This will become a hard error in meson 2.0.

authors_file = custom_target('AUTHORS',
  ##input : AUTHORS_TEXT,
  input : [authors_text_ss.full_path(), authors_data.full_path()],
  output: 'AUTHORS',
  command: [
    xsltproc,
    '--verbose',
    '-o', '@OUTPUT@',
    '@INPUT@',
  ],
  build_by_default: true,
)
msgtext = 'Common: @0@'.format(authors_common_ss.full_path())
message(msgtext)

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
    output: ['dummy'],
    command: [
        'cp',
        # Special case here since authors.xml is only available
        # in the build dir!
        meson.project_build_root()  + '/' + authors_file_xml,
        meson.project_source_root() + authors_subdir + authors_file_xml,
    ],
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

# pot needs generated authors.xml in src/preface
subdir('pot')

# Generate translated xml files...
subdir('src')
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
