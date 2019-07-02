lib="$TKD_RUBY_XZ";
version="$TKD_RUBY_XZ_VERSION";
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
  curl -o "$lib-$version.tar.gz" "https://razaoinfo.dl.sourceforge.net/project/lzmautils/$lib-$version.tar.gz"
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

if [ -e "$TKD_DEPENDENCIES_PATCHES/$lib-$version" ]; then
  echo "Patches found. Patching..."
for the_patch in `ls $TKD_DEPENDENCIES_PATCHES/$lib-$version`; do
  echo "Patching... $the_patch"
  patch -p0 < $TKD_DEPENDENCIES_PATCHES/$lib/$version/$the_patch
done
  echo "Done."
fi

./configure --prefix=$prefix_path\
            --enable-static\
            --disable-shared\
            --with-libiconv-prefix="$(pkg-config libiconv --variable=prefix)"
make
make test
make install

mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
cd $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
rm $TKD_RUBY_XZ_PCONFIG.pc
ln -s ../current/$lib/lib/pkgconfig/$TKD_RUBY_XZ_PCONFIG.pc

cd $TKD_RUBY_DEPENDENCIES_HOME

mkdir -p bin
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
