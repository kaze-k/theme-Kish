function prompt_cmd_duration -d 'Display the elapsed time of last command'
  set -l seconds ''
  set -l minutes ''
  set -l hours ''
  set -l days ''

  # Only if command duration is set  
  if set -q CMD_DURATION
    set -l cmd_duration (expr $CMD_DURATION / 1000)
    if [ $cmd_duration -gt 0 ]
      set seconds ' '(expr $cmd_duration \% 86400 \% 3600 \% 60)'s'
      if [ $cmd_duration -ge 60 ]
        set minutes ' '(expr $cmd_duration \% 86400 \% 3600 / 60)'m'
      end
      if [ $cmd_duration -ge 3600 ]
        set hours ' '(expr $cmd_duration \% 86400 / 3600)'h'
      end
      if [ $cmd_duration -ge 86400 ]
        set days ' '(expr $cmd_duration / 86400)'d'
      end

      set_color -i -d blue
      printf '⚑%s%s%s%s' $days$hours$minutes$seconds
      set_color normal
    end
  end
end

function prompt_exit_code -d "Display the exit code of last command"
  set -l exit_code $status

  if test $exit_code -ne 0
    set_color red
  else
    set_color green
  end
  printf ' [%d]' $exit_code
  set_color normal
end

function prompt_time -d "define the appearance of the right-side command line prompt"
  set_color yellow
  printf ' %s' (date +%H:%M:%S)
  set_color normal
end

function fish_right_prompt -d "Display the right prompt"
  prompt_cmd_duration
  prompt_exit_code
  prompt_time
end
