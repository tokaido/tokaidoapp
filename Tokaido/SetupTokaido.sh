#!/bin/bash

#  SetupTokaido.sh
#  Tokaido
#
#  Created by Patrick B. Gibson on 10/23/12.
#  Copyright (c) 2012 Tilde. All rights reserved.

clear

BIN="$HOME/.tokaido/bin"

export TOKAIDO_GEM_HOME=$HOME/.tokaido/Gems
export GEM_HOME=$TOKAIDO_GEM_HOME
export GEM_PATH=$TOKAIDO_GEM_HOME
export PATH=$BIN:$TOKAIDO_PATH:$GEM_HOME/bin:$PATH

if [ -d /Applications/Postgres.app ]; then
  export PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"
  echo -e "\033[0;32mTokaido detected Postgres.app and added it to the PATH\033[00m"
fi

cd "$TOKAIDO_APP_DIR"

echo -e "\033[0;32mThis terminal is now ready use with Tokaido.\033[00m"
echo