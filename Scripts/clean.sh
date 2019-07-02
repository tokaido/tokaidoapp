#!/bin/sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/environment.sh"

echo "Cleaning..."
rm -Rf $TKD_RUBY_DEPENDENCIES_HOME

sudo sh Tokaido/uninstall.sh
rm -Rf $root/b/dist/$TKD_RUBY
rm $root/b/dist/${TKD_RUBY}.zip
rm -Rf tmp
echo "done."
