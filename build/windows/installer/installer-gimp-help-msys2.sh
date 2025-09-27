# Install Inno Setup.
wget https://jrsoftware.org/download.php/is.exe
./is.exe //SILENT //SUPPRESSMSGBOXES //CURRENTUSER //SP- //LOG="innosetup.log"

# Install unofficial language files. These are translations of "unknown
# translation quality or might not be maintained actively".
# Cf. https://jrsoftware.org/files/istrans/
ISCCDIR=`grep "Dest filename:.*ISCC.exe" innosetup.log | sed 's/.*Dest filename: *\|ISCC.exe//g'`
ISCCDIR=`cygpath -u "$ISCCDIR"`
mkdir -p "${ISCCDIR}/Languages/Unofficial"
cd "${ISCCDIR}/Languages/Unofficial"

download_lang ()
{
  langfile="$1"
  rm -f "$langfile"
  wget "https://raw.githubusercontent.com/jrsoftware/issrc/main/Files/Languages/Unofficial/$langfile"
  downloaded="$?"
  if [ $downloaded -ne 0 ]; then
    echo "Download of '$langfile' failed."
    exit 1
  fi
}

download_lang_official ()
{
  langfile="$1"
  rm -f "$langfile"
  wget "https://raw.githubusercontent.com/jrsoftware/issrc/main/Files/Languages/$langfile"
  downloaded="$?"
  if [ $downloaded -ne 0 ]; then
    echo "Download of '$langfile' failed."
    exit 1
  fi
}

add_bom ()
{
  langfile="$1"
  file "$langfile" |grep "with BOM" 2>&1 > /dev/null
  has_bom="$?"
  if [ $has_bom -ne 0 ]; then
    sed -i "1s/^/\xEF\xBB\xBF/" "$langfile"
  fi
}

download_lang ChineseSimplified.isl
download_lang Croatian.isl
download_lang EnglishBritish.isl
download_lang Esperanto.isl
download_lang Farsi.isl
download_lang Greek.isl
download_lang Lithuanian.isl
download_lang NorwegianNynorsk.isl
download_lang Romanian.isl
cd -

# Any language not in a release yet, but moved from Unofficial, should be added here
cd "${ISCCDIR}/Languages/"
download_lang_official Korean.isl
download_lang_official Swedish.isl
cd -

# Copy generated language files into the source directory.
#cp _build-w64/build/windows/installer/lang/*isl build/windows/installer/lang

# Construct now the installer.
MAJOR_VERSION=`grep 'm4_define(\[help_major_version' configure.ac |sed 's/m4_define(\[help_major_version.*\[\([0-9]*\)\].*/\1/'`
MINOR_VERSION=`grep 'm4_define(\[help_minor_version' configure.ac |sed 's/m4_define(\[help_minor_version.*\[\([0-9]*\)\].*/\1/'`
MICRO_VERSION=`grep 'm4_define(\[help_micro_version' configure.ac |sed 's/m4_define(\[help_micro_version.*\[\([0-9]*\)\].*/\1/'`
cd build/windows/installer
./build.bat ${MAJOR_VERSION} ${MINOR_VERSION} ${MICRO_VERSION}

# Test if the installer was created and return success/failure.
MISSING_INSTALLER=0

cd _Output/
for dir in ../../../../po/*/
do
  code=`basename $dir`
  INSTALLER_BASE="gimp-help-${MAJOR_VERSION}.${MINOR_VERSION}.${MICRO_VERSION}"
  INSTALLER="$INSTALLER_BASE-$code-setup.exe"
  if [ -f "$INSTALLER" ]; then
    sha256sum $INSTALLER >> ${INSTALLER_BASE}.SHA256SUMS
    sha512sum $INSTALLER >> ${INSTALLER_BASE}.SHA512SUMS
  else
    MISSING_INSTALLER=1
    echo "Missing installer: $INSTALLER"
  fi
done

exit $MISSING_INSTALLER
