#!/bin/sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/environment.sh"

echo "Cleaning..."

rm -Rf $TKD_RUBY_DEPENDENCIES_HOME
rm -Rf b/dist/$TKD_RUBY

rm b/dist/${TKD_RUBY}.zip
rm Tokaido/Rubies/${TKD_RUBY}.zip

rm -Rf Tokaido/Versions
rm -Rf tmp
echo "done."
