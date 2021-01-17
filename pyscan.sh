#!/usr/bin/env bash

# PySCAN main shellscript code
#
# This shellscript is a bi-lingual shellscript/python file - which runs a self-contained 
# Python script with the latest available Python interpreter, auto-installs dependencies (DEPS), and auto-installs 
# multiple Python versions if the minimum version isn't available.
#
###################
# (C) 2021 Privex Inc. ( https://www.privex.io )
# Written by Chris (Someguy123) @ Privex Inc.
#
# Repo: https://github.com/Privex/pyscan
#
# Released under X11 / MIT license
###################
#
# When this file is ran as an executable, it tries to determine the
# highest version of Python which has the required dependencies installed.
#
# If there isn't a Python version available that meets MIN_VER, it will attempt to use the OS package manager
# to install all available versions of Python, ranging from 3 (default system python), and 3.6 to 3.9
#
# Once a suitable Python version is installed, it will scan for 'python3.9', down to 3.6, and finally 3 (python3).
#
# If the highest python version doesn't seem to have the required dependencies (DEPS) installed, then it will
# attempt to install them using pip (python3.x -m pip install -U [DEP])
#
# Once the highest version has been found, this script simply executes itself using Python, which will ignore
# shellscript and run the python body
#
###################
# Original source of bilingual script: https://stackoverflow.com/a/47886254/2648583
#
# Shell commands follow
# Next line is bilingual: it starts a comment in Python, and is a no-op in shell

""":"

: ${DEBUG=0}

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"
if [ -z ${DEPS+x} ]; then
  DEPS=('privex-helpers' 'privex-loghelper' 'attrs' 'colorama' 'rich')
fi

: ${USE_DATACLASSES=1}
: ${MIN_VER=3060}
: ${PREF_VER=3070}

export DEBIAN_FRONTEND="noninteractive"

OS_TYPE="" _YUM_CMD="yum" _APT_CMD="apt-get" INDEX_UPDATED=0
PKG_MGR="" PKG_MGR_UPDATE="" PKG_MGR_AVAIL=""

HIGHEST_VER=0

dbg() { 
    (( DEBUG )) && >&2 echo -e "$@" || true 
}

# scans argument 1 for python version, returns the version as an integer from 3040 (3.4) to 3100 (3.10)
_pyver() {
    local _xver=0
    grep -Eqi "^python 3.4" <<< "$1" && _xver=3040
    grep -Eqi "^python 3.5" <<< "$1" && _xver=3050
    grep -Eqi "^python 3.6" <<< "$1" && _xver=3060
    grep -Eqi "^python 3.7" <<< "$1" && _xver=3070
    grep -Eqi "^python 3.8" <<< "$1" && _xver=3080
    grep -Eqi "^python 3.9" <<< "$1" && _xver=3090
    grep -Eqi "^python 3.10" <<< "$1" && _xver=3100
    echo "$_xver"
}

# scan python 3.10 to 3.6 plus system python3 to discover which is the highest version installed
for cmd in python3.10 python3.9 python3.8 python3.7 python3.6 python3 ; do
    if command -v "$cmd" &>/dev/null; then
        dbg " [DBG] Found interpreter $cmd - checking version"
        PVER="$("$cmd" -V)"
        IVER="$(_pyver "$PVER")"
        if (( IVER > HIGHEST_VER )); then 
            dbg " [DBG] New highest version: $IVER"
            HIGHEST_VER=$IVER
        fi
    fi
done

# Configure PKG_MGR vars for a redhat based system
_pkg-rhel() {
    command -v dnf &>/dev/null && _YUM_CMD="dnf"
    PKG_MGR_AVAIL="$_YUM_CMD info"
    PKG_MGR="$_YUM_CMD install -y" OS_TYPE="redhat"
}

# Configure PKG_MGR vars for a debian based system
_pkg-deb() {
    command -v apt &>/dev/null && _APT_CMD="apt"
    PKG_MGR_UPDATE="$_APT_CMD update -qy" PKG_MGR_AVAIL="$_APT_CMD show"
    PKG_MGR="$_APT_CMD install --no-install-recommends -qy" OS_TYPE="debian"
}

# return 0 if a package is available (or if we don't support checking and we just have to hope it installs)
_pkg-avail() {
    if [[ -n "$PKG_MGR_AVAIL" ]]; then
        eval "$PKG_MGR_AVAIL $1" &> /dev/null
        return $?
    fi
    return 0
}

# install 1 or more packages. handles running package mgr update cmd if available
# plus checks if packages are available using _pkg-avail to avoid wasteful failures
_pkg-inst() {
    if ! (( INDEX_UPDATED )) && [[ -n "$PKG_MGR_UPDATE" ]]; then
        eval "$PKG_MGR_UPDATE"
        export INDEX_UPDATED=1
    fi
    avail_pkgs=()
    for p in "$@"; do
        if _pkg-avail "$p"; then
            avail_pkgs+=("$p")
        fi
    done
    if (( ${#avail_pkgs[@]} > 0 )); then
        eval "$PKG_MGR ${avail_pkgs[*]}"
        _ret=$?
        if (( _ret )); then
            for p in "${avail_pkgs[@]}"; do
                eval "$PKG_MGR $p"
            done
        fi
    fi
}

if [[ -f "/etc/debian_version" ]]; then
    dbg " [...] Found /etc/debian_version - must be debian based."; _pkg-deb
elif [[ -f "/etc/redhat-release" ]]; then
    dbg " [...] Found /etc/redhat-release - must be RedHat based."; _pkg-rhel
elif grep -qi "darwin" <<< "$(uname -a)"; then
    dbg " [...] Kernel is darwin! Must be macOS. Installing fontforge via brew"; PKG_MGR="brew install"
else
    if command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
        dbg " [...] Found apt-get / apt package manager. Probably debian based."; _pkg-deb
    elif command -v yum &>/dev/null || command -v dnf &>/dev/null; then
        dbg " [...] Found yum or dnf package manager. Probably redhat based."; _pkg-rhel
    elif command -v apk &>/dev/null; then
        dbg " [...] Found apk package manager. Probably Alpine based."; PKG_MGR="apk add"
    elif command -v brew &>/dev/null; then
        dbg " [...] Found brew package manager. Probably macOS based."; PKG_MGR="brew install"
    else
        dbg " [!!!] COULD NOT IDENTIFY DISTRO. Cannot ensure python + dependencies installed"
    fi
fi

if (( HIGHEST_VER < MIN_VER )); then
    if [[ "$OS_TYPE" == "debian" ]]; then
        {
            echo -e " [...] Attempting to install highest possible Python version via APT (${PKG_MGR}) package manager"

            _pkg-inst python3 python3-dev python3-pip python3-venv 
            _pkg-inst python3.6 python3.6-dev python3.6-pip \
                      python3.7 python3.7-dev python3.7-pip \
                      python3.8 python3.8-dev python3.8-pip \
                      python3.9 python3.9-dev python3.9-pip
        } >&2 
    elif [[ "$OS_TYPE" == "redhat" ]]; then
        {
            echo -e " [...] Attempting to install highest possible Python version via yum '${PKG_MGR}' package manager"
            _pkg-inst epel-release
            _pkg-inst gcc
            _pkg-inst python3 python3-devel python3-pip
            _pkg-inst python36 python36-devel python36-pip \
                      python37 python37-devel python37-pip \
                      python38 python38-devel python38-pip \
                      python39 python39-devel python39-pip

        } >&2 
    else
        if [[ -z "$PKG_MGR" ]]; then
             >&2 echo " [!!!] COULD NOT DETECT PACKAGE MANAGER. Cannot install/update python"
        else
            {
                echo -e " [...] Package manager '${PKG_MGR}' is not properly supported by this script"
                echo -e " [...] However, we will try our best to install the latest Python version possible...\n"
                if [[ -n "$PKG_MGR_UPDATE" ]]; then
                    eval "$PKG_MGR_UPDATE"
                fi
                eval "$PKG_MGR python3" 
                eval "$PKG_MGR python3-pip" 
                eval "$PKG_MGR python3-dev" 
                eval "$PKG_MGR python3-devel" 
                eval "$PKG_MGR python3-venv" 
                eval "$PKG_MGR python3.7" 
                eval "$PKG_MGR python37" 
                eval "$PKG_MGR python3.8" 
                eval "$PKG_MGR python38"
                eval "$PKG_MGR python3.9" 
                eval "$PKG_MGR python39"
            } >&2
        fi
    fi
else
    dbg " [...] System already meets minimum python ver: MIN_VER=${MIN_VER} HIGHEST_VER=${HIGHEST_VER}\n"
fi

# Find a suitable python interpreter, newest first.

for cmd in python3.9 python3.8 python3.7 python3.6 python3 ; do
    dbg " [DBG] Checking if we have $cmd"

    if command -v "$cmd" &>/dev/null; then
        dbg " [DBG] Found interpreter $cmd - checking python dependencies"
        INSTALLED_DEPS="$(env "$cmd" -m pip freeze)" MISSING_DEPS=0
       for d in "${DEPS[@]}"; do
           if ! grep -q "$d" <<< "$INSTALLED_DEPS"; then
               dbg " [DBG] Missing dependency: $d"
               MISSING_DEPS=1
           fi
       done
       if (( MISSING_DEPS )); then
           dbg " [DBG] Installing all dependencies: ${DEPS[*]}"
           env "$cmd" -m pip install -U "${DEPS[@]}" > /dev/null
       fi
       # if the python ver is < 3.7, and USE_DATACLASSES is true, then install the backported dataclasses package
       PY_VER="$($cmd -V)"
       IVER="$(_pyver "$PY_VER")"
       if (( IVER < 3070 )) && (( USE_DATACLASSES )); then
           if ! grep -q "dataclasses" <<< "$INSTALLED_DEPS"; then
               dbg " [DBG] Missing dependency: dataclasses (< py3.7)"
               dbg " [DBG] Installing dependency: dataclasses"
               env "$cmd" -m pip install -U dataclasses > /dev/null
           fi
       fi
       # Re-execute this script using the appropriate Python interpreter.
       exec $cmd $0 "$@"
       exit $?
    fi
done

>&2 echo -e "\n [!!!] CRITICAL ERROR: No python3 interpreter could be found...\n"

exit 2


":"""

# Previous line is bilingual: it ends a comment in Python, and is a no-op in shell
# Shell commands end here
# Python script to be appended below this line.

