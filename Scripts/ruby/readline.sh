lib="$TKD_RUBY_READLINE";
version="$TKD_RUBY_READLINE_VERSION";
prefix_path="$TKD_RUBY_DEPENDENCIES_PATH/$lib"

if [ -d "$prefix_path" ]; then
  echo "Previous $lib built. Deleting..."
  rm -Rf "$prefix_path"
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
  curl -o "$lib-$version.tar.gz" "https://ftp.gnu.org/gnu/readline/$lib-$version.tar.gz"
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

export  CFLAGS="$(pkg-config ncurses --cflags) $CFLAGS";
export LDFLAGS="$(pkg-config ncurses --libs) $LDFLAGS";


./configure --prefix=$prefix_path\
            --build=$TKD_ARCH-apple-$TKD_DARWIN\
            --disable-shared\
            --enable-static\
            --with-curses\
            --disable-install-examples\

make
make test
make install

mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
rm $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig/$TKD_RUBY_READLINE_PCONFIG.pc
rm $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/lib/pkgconfig/$TKD_RUBY_READLINE_PCONFIG.pc
# readline generates pkgconfig file with termcap as private requirement (but missing)
# replacing it...
# so we generate one.
if [ ! -z "$TKD_RELEASE" ]; then
  cp $TKD_DEPENDENCIES_HOME/$TKD_RUBY_READLINE/$TKD_RUBY_READLINE_VERSION/$TKD_RUBY_READLINE_PCONFIG.pc $prefix_path/lib/pkgconfig/$TKD_RUBY_READLINE_PCONFIG.pc
else
  cp $TKD_DEPENDENCIES_HOME/$TKD_RUBY_READLINE/$TKD_RUBY_READLINE_VERSION/$TKD_RUBY_READLINE_PCONFIG.dev.pc $prefix_path/lib/pkgconfig/$TKD_RUBY_READLINE_PCONFIG.pc
fi

cd $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
ln -sf ../current/$lib/lib/pkgconfig/$TKD_RUBY_READLINE_PCONFIG.pc

cd $TKD_RUBY_DEPENDENCIES_HOME

mkdir -p libs
mkdir -p include

rm include/$lib;

ln -sf ../current/$lib/include include/$lib

for f in `find "$TKD_RUBY_DEPENDENCIES_HOME/current/$lib/lib" -name "*.*a" | xargs -I{} basename {}`; do
  ln -sf ../current/$lib/lib/$f libs/$f
done

rm -Rf $prefix_path/bin
rm -Rf $prefix_path/share
rm -Rf $prefix_path/man

