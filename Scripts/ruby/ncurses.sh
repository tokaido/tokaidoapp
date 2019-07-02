lib="$TKD_RUBY_NCURSES";
version="$TKD_RUBY_NCURSES_VERSION";
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
  curl -o "$lib-$version.tar.gz" "https://ftp.gnu.org/gnu/ncurses/$lib-$version.tar.gz"
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

./configure --prefix=$prefix_path\
            --build=x86_64-apple-$TKD_DARWIN\
            --with-pkg-config-libdir=$prefix_path/lib/pkgconfig\
            --without-shared\
            --enable-pc-files\
            --enable-mixed-case\
            --enable-sigwinch\
            --enable-symlinks\
            --with-gpm=no\
            --without-debug

make
make test
make install

cd $TKD_RUBY_DEPENDENCIES_HOME
mkdir -p pkgconfig

for conf_file in `ls $prefix_path/lib/pkgconfig/`; do
  cd $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
  rm $conf_file
  ln -s ../current/$lib/lib/pkgconfig/$conf_file
done

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
