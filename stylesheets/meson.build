# Stylesheets (XML and css)

# Define authors and maintainers sources

# --- AUTHORS ---

# list of authors and contributors
AUTHORS_DATA_XML            = 'authors.xml'

AUTHORS_COMMON              = 'authors_common.xsl'
# Stylesheet for the text version
AUTHORS_TEXT_STYLESHEETS    = 'authors_text.xsl'
# Stylesheet for the docbook xml version
AUTHORS_DOCBOOK_STYLESHEETS = 'authors_docbook.xsl'
# Authors DTD
AUTHORS_DTD                 = 'authors.dtd'

# automatically generated authors section (DocBook)
##AUTHORS_DOCBOOK_XML = 'src/preface/authors.xml'
AUTHORS_DOCBOOK_XML = 'authors.xml'
#AUTHORS_DOCBOOK_DIRNAME = $(dir $(AUTHORS_DOCBOOK_XML))
#AUTHORS_DOCBOOK_FILENAME = $(notdir $(AUTHORS_DOCBOOK_XML))

AUTHORS_TEXT    = [ AUTHORS_COMMON + AUTHORS_TEXT_STYLESHEETS    + AUTHORS_DATA_XML ]
AUTHORS_DOCBOOK = [ AUTHORS_COMMON + AUTHORS_DOCBOOK_STYLESHEETS + AUTHORS_DATA_XML ]

AUTHORS_ALL     = [ AUTHORS_DATA_XML + AUTHORS_COMMON + AUTHORS_TEXT_STYLESHEETS + \
    AUTHORS_DOCBOOK_STYLESHEETS + AUTHORS_DTD ]

authors_data = configure_file(
    input: AUTHORS_DATA_XML,
    output: AUTHORS_DATA_XML,
    copy: true,
)

authors_common_ss = configure_file(
    input : AUTHORS_COMMON,
    output: AUTHORS_COMMON,
    copy: true,
    #install: true,
)

authors_text_ss = configure_file(
    input : AUTHORS_TEXT_STYLESHEETS,
    output: AUTHORS_TEXT_STYLESHEETS,
    copy: true,
    #install: true,
)

authors_text_dtd = configure_file(
    input : AUTHORS_DTD,
    output: AUTHORS_DTD,
    copy: true,
    #install: true,
)

authors_docbook_ss = configure_file(
    input : AUTHORS_DOCBOOK_STYLESHEETS,
    output: AUTHORS_DOCBOOK_STYLESHEETS,
    copy: true,
    #install: true,
)

# --- MAINTAINERS ---

# Stylesheet generating MAINTAINERS
DOAP_STYLESHEET = ['doap2text.xsl']

# Maintainers doap resides in the root
# MAINTAINERS_DOAP = ['gimp-help.doap']

#MAINTAINERS_TEXT = DOAP_STYLESHEET + MAINTAINERS_DOAP

MAINTAINERS_ALL  = DOAP_STYLESHEET

# Copy authors + maintainers related files

STYLESHEET_ALL  = AUTHORS_ALL + MAINTAINERS_ALL

# foreach ss_file: STYLESHEET_ALL
#     stylesheet_file = configure_file(
#       input : ss_file,
#       output: ss_file,
#       copy: true,
#       #install: true,
#     )
# endforeach


### Taken from configure.ac ###
#  Default to the correct way of identifying stylesheets.
#  People need an XML catalog to resolve this to a local file.

STYLEBASE='http://docbook.sourceforge.net/release/xsl/current'

xslconfig = configuration_data()
xslconfig.set('STYLEBASE',     STYLEBASE)
xslconfig.set('ALL_LINGUAS',   ALL_LINGUAS)

# Needs replacing STYLEBASE and ALL_LINGUAS
plainhtml = configure_file(
  input : 'plainhtml.xsl.in',
  output: 'plainhtml.xsl',
  configuration: xslconfig,
  #install: true,
)
# plainhtml_target = custom_target(
#   input: plainhtml,
#   output: 'dummy',

# )

# There seem to be no strings that need replacing! (Just remove the ".in" version?)
htmlalternate = configure_file(
  input : 'htmlalternate.xsl.in',
  output: 'htmlalternate.xsl',
  configuration: xslconfig,
  #install: true,
)

drafthtml = configure_file(
  input : 'drafthtml.xsl',
  output: 'drafthtml.xsl',
  copy: true,
  #install: true,
)

plainprint = configure_file(
  input : 'plainprint.xsl',
  output: 'plainprint.xsl',
  copy: true,
  #install: true,
)

lang_menu = configure_file(
  input : 'languageMenu.xsl',
  output: 'languageMenu.xsl',
  copy: true,
  #install: true,
)

lang_vocab = configure_file(
  input : 'languageVocab.xml',
  output: 'languageVocab.xml',
  copy: true,
  #install: true,
)

makeindex = configure_file(
  input : 'makeindex.xsl',
  output: 'makeindex.xsl',
  copy: true,
  #install: true,
)
floatimages = configure_file(
  input : 'float-images.xsl',
  output: 'float-images.xsl',
  copy: true,
  #install: true,
)

getsortkey = configure_file(
  input : 'getsortkey.xsl',
  output: 'getsortkey.xsl',
  copy: true,
  #install: true,
)
entities = configure_file(
  input : 'entities.xml',
  output: 'entities.xml',
  copy: true,
  #install: true,
)
