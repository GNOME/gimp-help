message('quickreference subdir')

keys_xml = files('gimp-keys.xml')

subdir('stylesheets')
subdir('templates')
subdir('po')

# Generate translated xml files
subdir('xml')
# Convert to svg
subdir('svg')
# Convert to pdf
subdir('pdf')

#FIXME: the Makefile.am also has a target to convert to docbook.xml
#       Since that is currently never used, we will leave that for
#       another time. Maybe when we fugure out how to integrate this
#       with the rest of the manual.
