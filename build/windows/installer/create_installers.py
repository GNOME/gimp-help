#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
#
# create_installers.py - Create Windows installers
# Copyright (c) 2026 Jacob Boerema.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


import os, sys
import getopt
import subprocess
import shutil
import winreg           # Get InnoSetup install path
import urllib.request   # Download InnoSetup
import hashlib          # Create sha*sum

VERBOSE = False
VERSION = 0.1


def printVersion():
    print(f"\ncreate_installers.py v {VERSION}")

def usage():
    printVersion()
    print("""Creates Windows installers for selected languages.

usage: create_installers.py [options] installed-html-dir

    installed-html-dir          Directory where the html files are located,
                                not including the language directory.

    options:
        -g      --ver           gimp-help version (three parts) If omitted expects
                                a file called "gimp-help.version" in the build dir
                                with the version on the first line.
        -l      --lang          A list of language codes or "all" (default)
        -h      --help          this help""")
# There's also -v, --verbose but we currently don't use that.


def download_inno():
    # TODO: Figure out what the latest release is
    # For now we use the latest known 6.7 release
    inno_setup_6 = 'https://github.com/jrsoftware/issrc/releases/download/is-6_7_3/innosetup-6.7.3.exe'
    is_name      = 'is.exe'

    try:
        is_path, _headers = urllib.request.urlretrieve(inno_setup_6, is_name)

        print(f"InnoSetup save at {is_path}")

    except urllib.error.HTTPError as e:
        print(f"Failed to download InnoSetup: Status Code {e.code}")
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"Failed to download InnoSetup: failed to connect to the server")
        sys.exit(1)

    print("Installing InnoSetup")
    try:
        subprocess.run(
            [is_path,
                "//SILENT",
                "//SUPPRESSMSGBOXES",
                "//CURRENTUSER",
                "//SP-",
                "//LOG=innosetup.log",
            ],
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"Failed to install InnoSetup: {e.stderr}")
        sys.exit(1)


def get_inno_install_path():
    # TODO Possibly check envvar first for override?
    inno_versions = ['7', '6']
    for ver in inno_versions:
        innokey = f"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Inno Setup {ver}_is1"

        try:
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, innokey, 0, winreg.KEY_READ | winreg.KEY_WOW64_32KEY) as key:
                try:
                    path, _ = winreg.QueryValueEx(key, "Inno Setup: App Path")
                    return path
                except FileNotFoundError:
                    continue
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, innokey, 0, winreg.KEY_READ | winreg.KEY_WOW64_32KEY) as key:
                try:
                    path, _ = winreg.QueryValueEx(key, "Inno Setup: App Path")
                    return path
                except FileNotFoundError:
                    continue
        except FileNotFoundError:
            continue

    return None


def get_inno_repo(local_dir):
    repo_url = "https://github.com/jrsoftware/issrc.git"

    if not os.path.exists(local_dir):
        try:
            subprocess.run(["git", "clone", "--depth", "1", repo_url, local_dir], check=True)
            print("Repository cloned successfully!")
        except subprocess.CalledProcessError as e:
            print(f"Could not clone {repo_url}: {e}")
            sys.exit(1)
    else:
        try:
            subprocess.run(["git", "pull", "--depth=1"], cwd=local_dir, check=True)
            print("Repository updated successfully!")
        except subprocess.CalledProcessError as e:
            print(f"Could not update {repo_url}: {e}")


def copy_lang_files (src_path, dest_path):
    if not os.path.exists(src_path):
        print(f"Source path {src_path} does not exist!")
        sys.exit(1)
    elif not os.path.exists(dest_path):
        print(f"Destination {dest_path} does not exist!")
        sys.exit(1)

    # Copy all official languages
    shutil.copytree(src_path, dest_path, dirs_exist_ok=True, ignore=shutil.ignore_patterns("Unofficial"))

    # Add  all unofficial languages to same dir, that way
    # we don't need changes if a lang moves from/to unofficial
    shutil.copytree(src_path + 'Unofficial/', dest_path, dirs_exist_ok=True, ignore=shutil.ignore_patterns("Unofficial"))


def create_inno_installers(selected_languages, inno_dir, build_dir, html_dir, version):
    inno_exe_path = inno_dir  + "ISCC.exe"
    iss_path      = build_dir + 'build/windows/installer/'
    succeeded     = True

    for lang in selected_languages:
        try:
            subprocess.run([
                    inno_exe_path, "gimp-help.iss",
                    "/DMAJORVERSION=" + version[0],
                    "/DMINORVERSION=" + version[1],
                    "/DMICROVERSION=" + version[2],
                    "/DLANG="         + lang,
                    "/DHELPDIR="      + html_dir,
                ],
                cwd=iss_path,
                check=True
            )
        except subprocess.CalledProcessError as e:
            print(f"Creating installer for {lang} failed!")
            succeeded = False

    return succeeded


def generate_checksums(build_dir, version_str, languages):

    output_path = build_dir + 'build/windows/installer/_Output/'

    installer_base_name = f"gimp-help-{version_str}"
    sha256_file         = output_path + installer_base_name + '.SHA256SUMS'
    sha512_file         = output_path + installer_base_name + '.SHA512SUMS'


    with open(sha256_file, "w", encoding="utf-8") as log_file:
        # No further writing needed here: we're just truncating the file
        pass
    with open(sha512_file, "w", encoding="utf-8") as log_file:
        # No further writing needed here: we're just truncating the file
        pass

    for langcode in languages:
        installer_exe  = f"{installer_base_name}-{langcode}-setup.exe"
        installer_path = output_path + installer_exe

        sha256 = hashlib.sha256()
        sha512 = hashlib.sha512()

        # Calculate hashes in 1MB chunks
        with open(installer_path, "rb") as f:
            while chunk := f.read(1048576):
                sha256.update(chunk)
                sha512.update(chunk)

        with open(sha256_file, "a", encoding="utf-8") as file256, open(sha512_file, "a", encoding="utf-8") as file512:
            file256.write(f"{sha256.hexdigest()} *{installer_exe}\n")
            file512.write(f"{sha512.hexdigest()} *{installer_exe}\n")


def main(argv):
    global VERBOSE

    # default assume current directory is root_dir
    root_dir            = '.'
    local_dir_name      = 'inno_clone'
    inno_lang_dir_inst  = 'Languages/'
    inno_lang_dir_repo  = 'Files/Languages/'
    html_dir            = None
    languages           = []
    version_str         = None
    version             = None

    try:
        opts, remaining_args = getopt.getopt(argv, "hv:g:l",
            [
                "help", "verbose",
                "lang=", "ver=",
            ])
    except getopt.GetoptError as err:
        usage()
        sys.exit(1)

    for opt, arg in opts:
        if opt == "-h" or opt == "--help":
            usage()
            sys.exit(0)
        elif opt == "-v" or opt == "--verbose":
            VERBOSE = True
        elif opt == "-l" or opt == "--lang":
            # TODO Add handling of "all"
            if not arg == 'all':
                languages = arg.strip().split(' ')
        elif opt == "g" or opt == "--ver":
            version_str = arg
            version = version_str.split('.')
            if len(version) != 3:
                print(f"Invalid version {version_str}, should be 3 parts separated by a dot")
                sys.exit(1)


    if remaining_args is not None:
        if len(remaining_args) >= 1:
            html_dir = remaining_args[0]
            if not (html_dir.endswith("/") or html_dir.endswith("\\")):
                html_dir += '/'
            html_dir = os.path.abspath(html_dir)
            print(f"Absolute html dir: {html_dir}")

            if not os.path.exists(html_dir):
                print(f"Invalid html dir: {html_dir}")
                sys.exit(1)
        else:
            print(f"Missing html directory parameter")
            sys.exit(1)
    else:
        usage()
        sys.exit(1)

    root_dir = os.path.abspath(root_dir)
    if not (root_dir.endswith("/") or root_dir.endswith("\\")):
        root_dir += '/'

    if not os.path.exists(root_dir):
        print("Invalid root dir: {root_dir}")
        sys.exit(1)

    if not os.path.exists(root_dir + 'AUTHORS') and os.path.exists(root_dir + '_build'):
        # ci call starts from parent of _build
        root_dir += '_build/'
        # ci _build dir only has the build subdir, we can't test for what is done below
    elif not os.path.exists(root_dir + 'AUTHORS') or not os.path.exists(root_dir + 'quickreference'):
        print("Invalid root dir '{root_dir}'. It should be the build dir of gimp-help.")
        sys.exit(1)

    if version_str is None or version is None:
        # See if "gimp-help.version" exists in root build dir
        version_file = 'gimp-help.version'
        if not os.path.exists(root_dir + version_file):
            print("Missing gimp-help version!")
            sys.exit(1)
        else:
            with open(root_dir + version_file, "r", encoding="utf-8") as f:
                version_str = f.read()
                version = version_str.strip().split('.')
                if len(version) != 3 or not version[0].isdigit():
                    print(f"Invalid version {version_str}, should be 3 numbers separated by a dot")
                    sys.exit(1)

    # Find or download and install InnoSetup

    inno_dir = get_inno_install_path()
    if inno_dir is None:
        print("InnoSetup not found. We'll try to download it.")
        download_inno()

        inno_dir = get_inno_install_path()
        if inno_dir is None:
            print(f"InnoSetup path missing or not found in registry.")
            sys.exit(1)

    if not (inno_dir.endswith("/") or inno_dir.endswith("\\")):
        inno_dir += '/'
    installed_inno_lang_dir = inno_dir + inno_lang_dir_inst

    # Clone or update InnoSetup repo to have access to all languages

    local_inno_dir = root_dir + local_dir_name
    get_inno_repo(local_inno_dir)

    # Copy all languages to location of installed InnoSetup

    lang_dir = local_inno_dir + '/' + inno_lang_dir_repo
    if not os.path.exists(lang_dir):
        print(f"InnoSetup repository languages directory doesn't exist: {lang_dir}")
        sys.exit(1)

    copy_lang_files (lang_dir, installed_inno_lang_dir)

    if not create_inno_installers(languages, inno_dir, root_dir, html_dir, version):
        sys.exit(1)

    generate_checksums(root_dir, version_str, languages)


if __name__ == "__main__":
    main(sys.argv[1:])
