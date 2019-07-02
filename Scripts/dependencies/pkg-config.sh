lib="$TKD_RUBY_PKGCONFIG";
version="$TKD_RUBY_PKGCONFIG_VERSION";
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
  curl -o "$lib-$version.tar.gz" "https://$lib.freedesktop.org/releases/$lib-$version.tar.gz"
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
            --build=$TKD_ARCH-apple-$TKD_DARWIN_WITH_TINY\
            --with-pc-path=$TKD_RUBY_DEPENDENCIES_HOME/pkgconfig\
            --with-internal-glib\
            --enable-static

make
make test
make install

cd $TKD_RUBY_DEPENDENCIES_HOME

mkdir -p bin
mkdir -p pkgconfig

for f in `find "$TKD_RUBY_DEPENDENCIES_HOME/current/$lib/bin" -type f | xargs -I{} basename {}`; do
  ln -sf ../current/$lib/bin/$f bin/$f
done

rm -Rf $prefix_path/share
rm -Rf $prefix_path/man
