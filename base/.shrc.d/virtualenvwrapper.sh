if command -v virtualenvwrapper_lazy.sh >/dev/null; then
    . virtualenvwrapper_lazy.sh

    # for my dear Arch
    alias mktmpenv2="mktmpenv -p /usr/bin/python2"
    alias mkproject2="mkproject -p /usr/bin/python2"
    alias mkvirtualenv2="mkvirtualenv -p /usr/bin/python2"

    # pip will refuse to install packages outside of venvs
    export PIP_REQUIRE_VIRTUALENV="true"

    # unless we really mean to
    alias gpip="PIP_REQUIRE_VIRTUALENV= pip"
    alias gpip2="PIP_REQUIRE_VIRTUALENV= pip2"
    alias gpip3="PIP_REQUIRE_VIRTUALENV= pip3"

    # TODO: perhaps change WORKON_HOME to use XDG_DATA_HOME ?
fi
