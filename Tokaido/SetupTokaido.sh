#!/bin/bash

#  SetupTokaido.sh
#  Tokaido
#
#  Created by Patrick B. Gibson on 10/23/12.
#  Copyright (c) 2012 Tilde. All rights reserved.

BIN="/bin"
export GEM_HOME=$TOKAIDO_GEM_HOME
export GEM_PATH=$TOKAIDO_GEM_HOME$BIN
export PATH=$TOKAIDO_PATH:$GEM_PATH:$PATH


cd "$TOKAIDO_APP_DIR"

echo "This terminal is now ready use with Tokaido."