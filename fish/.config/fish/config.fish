if status is-login
  # Read the POSIX shells `profile`s
  # The -0 argument to env is non-standard but it's supported by GNU and
  # Busybox which is enough for me (for now).  `PWD` and `SHLVL` are readonly
  # so we skip them
  sh -c '
    [ -r /etc/profile ] && . /etc/profile
    [ -r ~/.profile ] && . ~/.profile
    env -0' | while read -lzd= name value
      test $name != PWD
      and test $name != SHLVL
      and set -xg $name $value
    end
end

if status is-interactive
  # Commands to run in interactive sessions can go here
end
