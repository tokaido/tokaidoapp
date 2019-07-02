#!/bin/sh

export root=$PWD

export TKD_VERSION="2.6.3-p62"
export TKD_HOME_DEV="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
export TKD_DEPENDENCIES_HOME="$TKD_HOME_DEV/Supplements"
export TKD_DEPENDENCIES_TARBALLS="$TKD_DEPENDENCIES_HOME/tarballs"

export TKD_DEPENDENCIES_CODE="$TKD_DEPENDENCIES_HOME/src"
export TKD_DEPENDENCIES_PATCHES="$TKD_DEPENDENCIES_HOME/patches"

export TKD_ARCH="x86_64"
export TKD_DARWIN="darwin12.5"
export TKD_DARWIN_TRUNCATED="darwin12"
export TKD_DARWIN_WITH_TINY="darwin12.5.0"
export TKD_ARCH_DARWIN="$TKD_ARCH-$TKD_DARWIN"

if [ ! -z "$TKD_RELEASE" ]; then  
  export TKD_RUBY_DEPENDENCIES_HOME="/Applications/Tokaido.app/Contents/Resources/Versions"
  export TKD_RUBY_DEPENDENCIES_PATH="/Applications/Tokaido.app/Contents/Resources/Versions/current"
else
  export TKD_RUBY_DEPENDENCIES_HOME="$TKD_DEPENDENCIES_HOME/Versions"
  export TKD_RUBY_DEPENDENCIES_PATH="$TKD_DEPENDENCIES_HOME/Versions/current"
fi 

export TKD_RUBY_VERSION="2.6.3"
export TKD_RUBY_PATCH_VERSION="p62"
export TKD_RUBY="$TKD_RUBY_VERSION-$TKD_RUBY_PATCH_VERSION"
export TKD_RUBY_NAMESPACE_TINY="2.6"
export TKD_RUBY_NAMESPACE="2.6.0"
export TKD_RUBY_ARCH_VERSION="$TKD_ARCH-$TKD_DARWIN_TRUNCATED"

# Extra libraries
export TKD_RUBY_SQLITE3="sqlite"
export TKD_RUBY_SQLITE3_PCONFIG="sqlite3"
export TKD_RUBY_SQLITE3_VERSION="autoconf-3280000"

export TKD_RUBY_XZ="xz"
export TKD_RUBY_XZ_PCONFIG="liblzma"
export TKD_RUBY_XZ_VERSION="5.2.4"

export TKD_RUBY_ICONV="libiconv"
export TKD_RUBY_ICONV_PCONFIG="libiconv"
export TKD_RUBY_ICONV_VERSION="1.16"

export TKD_RUBY_PKGCONFIG="pkg-config"
export TKD_RUBY_PKGCONFIG_VERSION="0.29.2"

# Core libraries
export TKD_RUBY_ZLIB="zlib"
export TKD_RUBY_ZLIB_PCONFIG=$TKD_RUBY_ZLIB
export TKD_RUBY_ZLIB_VERSION="1.2.11"

export TKD_RUBY_LIBFFI="libffi"
export TKD_RUBY_LIBFFI_PCONFIG="libffi"
export TKD_RUBY_LIBFFI_VERSION="3.2.1"

export TKD_RUBY_NCURSES="ncurses"
export TKD_RUBY_NCURSES_PCONFIG="ncurses"
export TKD_RUBY_NCURSES_VERSION="6.1"

export TKD_RUBY_LIBYAML="yaml"
export TKD_RUBY_LIBYAML_PCONFIG="yaml"
export TKD_RUBY_LIBYAML_VERSION="0.1.6"

export TKD_RUBY_LIBUTIL="libutil"
export TKD_RUBY_LIBUTIL_PCONFIG="libutil"
export TKD_RUBY_LIBUTIL_VERSION="51"

export TKD_RUBY_READLINE="readline"
export TKD_RUBY_READLINE_PCONFIG="readline"
export TKD_RUBY_READLINE_VERSION="8.0"

export TKD_RUBY_OPENSSL="openssl"
export TKD_RUBY_OPENSSL_PCONFIG="openssl"
export TKD_RUBY_OPENSSL_VERSION="1.1.1c"

export TKD_RUBY_LIBRARIES=($TKD_RUBY_ZLIB $TKD_RUBY_LIBFFI $TKD_RUBY_LIBYAML $TKD_RUBY_NCURSES $TKD_RUBY_READLINE $TKD_RUBY_OPENSSL)

export TKD_RUBY_MAJOR=2
export TKD_RUBY_MINOR=6
export TKD_RUBY_TINY=3

export PKG_CONFIG_PATH="$TKD_RUBY_DEPENDENCIES_HOME/pkgconfig:$PKG_CONFIG_PATH";

export PATH="$TKD_RUBY_DEPENDENCIES_HOME/bin:$PATH"

export RUBY_BINARY_PATH="$root/b/dist"
export COMPRESSED_SOURCE_PATH="$root/../compressed"
export BUILD_TOOLS_PATH="/Users/andraswhite/Code/static/builds"

export TKD_RAILS_VERSION="5.1.7"
export RAILS_GEMFILE="rails-$TKD_RAILS_VERSION";

if [ $TKD_RUBY_MINOR -gt 3 ]; then
  export NO_DOC_OPTION="--no-document"
else
  export NO_DOC_OPTION="--no-ri --no-rdoc"
fi

export TKD_TMP_PATH="$root/tmp"
export TKD_SUPPLEMENTS_PATH="$root/Supplements"
export TKD_EXTENSIONS_PATH=$TKD_SUPPLEMENTS_PATH
