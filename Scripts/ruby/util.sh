lib="$TKD_RUBY_LIBUTIL";
version="$TKD_RUBY_LIBUTIL_VERSION";
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
  curl -o "$lib-$version.tar.gz" "https://opensource.apple.com/tarballs/libutil/$lib-$version.tar.gz"
  cd $TKD_HOME_DEV
  echo "Done."
fi


cd $TKD_DEPENDENCIES_TARBALLS

tar xzvf $lib-$version.tar.gz $lib-$version > /dev/null 2>&1

cd $TKD_HOME_DEV
if [ -e "$TKD_DEPENDENCIES_CODE/$lib-$version" ]; then
echo ""
  rm -Rf $TKD_DEPENDENCIES_CODE/$lib-$version
fi

mv $TKD_DEPENDENCIES_TARBALLS/$lib-$version $TKD_DEPENDENCIES_CODE/$lib-$version
cd $TKD_DEPENDENCIES_CODE/$lib-$version

mkdir -p objs

export LANG=en_US.UTF-8
export CFLAGS="-I. -arch x86_64 -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -Wno-trigraphs -fpascal-strings -O0 -Wno-missing-field-initializers -Wmissing-prototypes -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-constant-conversion -Wno-int-conversion -Wno-bool-conversion -Wno-enum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -fasm-blocks -fstrict-aliasing -Wdeprecated-declarations -Wall";

gcc -I . -c getmntopts.c -o objs/getmntopts.o
gcc -I . -c humanize_number.c -o objs/humanize_number.o
gcc -I . -c pidfile.c -o objs/pidfile.o
gcc -I . -c realhostname.c -o objs/realhostname.o
gcc -I . -c reexec_to_match_kernel.c -o objs/reexec_to_match_kernel.o
gcc -I . -c trimdomain.c -o objs/trimdomain.o

clang++ -I. -arch x86_64 -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -Wno-trigraphs -fpascal-strings -O0 -Wno-missing-field-initializers -Wmissing-prototypes -Wno-non-virtual-dtor -Wno-overloaded-virtual -Wno-exit-time-destructors -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-constant-conversion -Wno-int-conversion -Wno-bool-conversion -Wno-enum-conversion -Wshorten-64-to-32 -Wno-newline-eof -Wno-c++11-extensions -fasm-blocks -fstrict-aliasing -Wdeprecated-declarations -Winvalid-offsetof -fvisibility-inlines-hidden -c wipefs.cpp -o objs/wipefs.o

libtool -o libutil.a objs/getmntopts.o objs/humanize_number.o objs/pidfile.o objs/realhostname.o objs/reexec_to_match_kernel.o objs/trimdomain.o
ranlib libutil.a

mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/libs
mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/include

mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/current/$lib
mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/include
mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/lib

cp libutil.h $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/include/libutil.h
cp mntopts.h $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/include/mntopts.h
cp wipefs.h $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/include/wipefs.h

cp libutil.a $TKD_RUBY_DEPENDENCIES_HOME/current/$lib/lib/libutil.a

# libutil doesn't generate pkgconfig file.so we generate one.
mkdir -p $prefix_path/lib/pkgconfig
if [ ! -z "$TKD_RELEASE" ]; then
  cp $TKD_DEPENDENCIES_HOME/$TKD_RUBY_LIBUTIL/$TKD_RUBY_LIBUTIL_VERSION/$TKD_RUBY_LIBUTIL_PCONFIG.pc $prefix_path/lib/pkgconfig/$TKD_RUBY_LIBUTIL_PCONFIG.pc
else
  cp $TKD_DEPENDENCIES_HOME/$TKD_RUBY_LIBUTIL/$TKD_RUBY_LIBUTIL_VERSION/$TKD_RUBY_LIBUTIL_PCONFIG.dev.pc $prefix_path/lib/pkgconfig/$TKD_RUBY_LIBUTIL_PCONFIG.pc
fi

cd $TKD_RUBY_DEPENDENCIES_HOME/pkgconfig
rm $TKD_RUBY_LIBUTIL_PCONFIG.pc
ln -sf ../current/$lib/lib/pkgconfig/$TKD_RUBY_LIBUTIL_PCONFIG.pc

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
