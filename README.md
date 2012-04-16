Compiling static ruby:

    git clone https://github.com/sm/sm.git && cd sm && ./install
    echo "export PATH=\"$HOME/.sm/bin:$HOME/.sm/pkg/active/bin:\$PATH\"" >> .bashrc
    source ~/.bashrc
    sm ext install tokaidoapp tokaido/tokaidoapp
    sm tokaidoapp dependencies
    sm tokaidoapp install

Ruby is isntalled in `$HOME/.sm/pkg/versions/tokaidoapp/1.9.3-p125/`

