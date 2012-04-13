#!/usr/bin/env bash

current_path="$PWD"
sandbox_path="$PWD/sandbox"
src_path="$PWD/sandbox/src"
target_path="$PWD/sandbox/target"
if [[ -n "${1:-}" ]]
then
  usr_dir="$1"
else
  echo "You need to specify path to compiled libraries."
  exit 1
fi

ruby_version=ruby-1.9.3-p125
ruby_package=${ruby_version}.tar.bz2
download_url=http://ftp.ruby-lang.org/pub/ruby/1.9/${ruby_package}

confirure_cmd=(
  ./configure --prefix="${target_path}" --enable-load-relative 
  --with-opt-dir="${usr_dir}" --with-static-linked-ext --disable-shared
)

rm -rf "${sandbox_path}"
mkdir -p "${src_path}" "${target_path}"

echo "-- Downloading"
(
  cd "${sandbox_path}" &&
  curl ${download_url} -o ${ruby_package} &&
  cd "${src_path}" &&
  tar xjf ../${ruby_package} --strip-components 1
) || {
  echo "Could not download/extract ruby package."
  exit 2
}

echo "-- Building"
(
  cd "${src_path}"    &&
  ${confirure_cmd[@]} > ../configure.log    2>&1 &&
  make                > ../make.log         2>&1 &&
  make install        > ../make.install.log 2>&1
) || {
  echo "failed to configure/build/install ruby."
  exit 3 
}

