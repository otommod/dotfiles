if command -v virtualenvwrapper_lazy.sh >/dev/null; then
    # TODO: perhaps change WORKON_HOME to use XDG_DATA_HOME ?
    . virtualenvwrapper_lazy.sh

    # for my dear Arch
    alias mktmpenv2="mktmpenv -p /usr/bin/python2"
    alias mkproject2="mkproject -p /usr/bin/python2"
    alias mkvirtualenv2="mkvirtualenv -p /usr/bin/python2"
fi
