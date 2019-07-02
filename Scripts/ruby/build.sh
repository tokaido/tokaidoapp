lib="ruby";
version="$TKD_RUBY_VERSION"
prefix_path="$root/b/dist/$version-$TKD_RUBY_PATCH_VERSION"

if [ -d "$prefix_path" ]; then
  rm -Rf "$prefix_path"
  rm $root/b/dist/$TKD_RUBY_VERSION-$TKD_RUBY_PATCH_VERSION.zip
fi

cd $TKD_HOME_DEV

mkdir -p $prefix_path
mkdir -p $TKD_DEPENDENCIES_TARBALLS
mkdir -p $TKD_DEPENDENCIES_CODE

if [ -f "$TKD_DEPENDENCIES_TARBALLS/$lib-$version.tar.gz" ]; then
  echo "$lib sources downloaded already. Skipping..."
else
  echo "Downloading $lib-$version..."
  cd $TKD_DEPENDENCIES_TARBALLS
  curl -o "$lib-$version.tar.gz" "https://cache.ruby-lang.org/pub/ruby/$TKD_RUBY_NAMESPACE_TINY/ruby-$version.tar.gz"
  cd $TKD_HOME_DEV
  echo "Done."
fi

cd $TKD_DEPENDENCIES_TARBALLS
tar xzvf $lib-$version.tar.gz $lib-$version > /dev/null 2>&1

cd $TKD_HOME_DEV

if [ -e "$TKD_DEPENDENCIES_CODE/$lib-$version" ]; then
  rm -Rf $TKD_DEPENDENCIES_CODE/$lib-$version
fi

mv $TKD_DEPENDENCIES_TARBALLS/$lib-$version $TKD_DEPENDENCIES_CODE/$lib-$version
cd $TKD_DEPENDENCIES_CODE/$lib-$version

cd $root/Scripts/ruby
sh ./zlib.sh
export  CFLAGS="$(pkg-config zlib --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config zlib --libs) $LDFLAGS";
sh ./libffi.sh
export  CFLAGS="$(pkg-config libffi --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config libffi --libs) $LDFLAGS";
sh ./yaml.sh
export  CFLAGS="$(pkg-config yaml --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config yaml --libs) $LDFLAGS";
sh ./ncurses.sh
export  CFLAGS="$(pkg-config ncurses --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config ncurses --libs) $LDFLAGS";
sh ./util.sh
export  CFLAGS="$(pkg-config libutil --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config libutil --libs) $LDFLAGS";
sh ./readline.sh
sh ./openssl.sh
export  CFLAGS="$(pkg-config openssl --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config openssl --libs) $LDFLAGS";
cd $TKD_DEPENDENCIES_CODE/$lib-$version

export CFLAGS="-I$TKD_RUBY_DEPENDENCIES_HOME/include $CFLAGS"
export LDFLAGS="-Bstatic -L$TKD_RUBY_DEPENDENCIES_HOME/libs $LDFLAGS";

./configure --prefix=$prefix_path\
            --build=$TKD_ARCH-apple-$TKD_DARWIN\
            --with-arch=$TKD_ARCH\
            --enable-load-relative\
            --disable-shared\
            --disable-install-doc\
            --with-out-ext=tk,sdbm,gdbm,dbm,dl,coverage\
            --sysconfdir=/etc\
            --with-readline-dir="$(pkg-config $TKD_RUBY_READLINE_PCONFIG --variable=prefix)"
#            --with-zlib-dir="$(pkg-config $TKD_RUBY_ZLIB_PCONFIG --variable=prefix)"

make
make test
make install
