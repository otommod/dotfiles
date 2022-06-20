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
  function notify_bell --on-event fish_prompt
    echo -en "\a"
  end

  # https://codeberg.org/dnkl/foot/wiki#jumping-between-prompts
  function mark_prompt_start --on-event fish_prompt
    echo -en "\e]133;A\e\\"
  end
end
