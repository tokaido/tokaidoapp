#!/bin/bash

export CC=gcc-4.2

sm set install all

sm ext install tokaidoapp tokaido/tokaidoapp
sm pkg-config install static
sm tokaidoapp dependencies
sm tokaidoapp install

sm sqlite3 install static

mkdir -p ./tmp_gem_home
GEM_HOME=./tmp_gem_home

function libdir() {
  typeset filename=$(find ~/.sm/pkg/active -name "$1*.a")
  echo $(dirname $filename)
}

echo $(libdir libsqlite3)
gem install sqlite3 --no-ri --no-rdoc -- --with-sqlite3-lib=$(libdir libsqlite3)
