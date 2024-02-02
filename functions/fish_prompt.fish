# name: Kish

function _git_branch_name -d "Display git branch name"
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e "s|^refs/heads/||")
end

function _is_git_dirty -d "Check if git repo is dirty"
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end

function _is_git_unpushed -d "Check if git repo has unpushed changes"
  echo (command git log @{upstream}..HEAD 2> /dev/null)
end

function _is_git_unpulled -d "Check if git repo has unpulled changes"
  echo (command git log HEAD..@{upstream} 2> /dev/null)
end

function _is_git_conflict -d "Check if git repo has conflicts"
  echo (command git ls-files --unmerged 2> /dev/null)
end

function _get_git_staged_count -d "Get number of staged files"
  echo (command git diff --cached --name-only --diff-filter=ACM | grep -v "$(git ls-files --unmerged)" | wc -l)
end

function _get_git_unstaged_count -d "Get number of unstaged files"
  echo (command git status --porcelain | grep "^ M" | wc -l)
end

function _get_git_untracked_count -d "Get number of untracked files"
  echo (command git ls-files --others --exclude-standard 2> /dev/null | wc -l)
end

function _get_git_stashed_count -d "Get number of stashed files"
  echo (command git stash list 2> /dev/null | wc -l)
end

function _get_git_conflict_count -d "Get number of conflicted files"
  echo (command git diff --name-only --diff-filter=U --relative 2> /dev/null | wc -l)
end

function _is_proxy -d "Check if proxy is set"
  echo (command env | grep -E "proxy|PROXY" 2> /dev/null)
end

function _is_virtual_env -d "Check if python virtual env is set"
  echo (command [ -n $VIRTUAL_ENV ] && echo $VIRTUAL_ENV | awk -F/ '{print $NF}')
end

function prompt_jobs -d "Display background jobs"
  set -l has_jobs (jobs -p | wc -l)

  if [ "$has_jobs" != 0 ]
    set_color -o cyan
    printf "[●]"
    set_color normal
  end
end

function prompt_virtual_env -d "Display python virtual env"
  if [ (_is_virtual_env) ]
    set_color -o green
    printf "(%s)" (_is_virtual_env)
    set_color normal
  end
end

function prompt_proxy -d "Display proxy"
  if [ (_is_proxy) ]
    set_color -o red
    printf "─<"
    set_color normal

    set_color -o magenta
    printf "VPN"
    set_color normal

    set_color -o red
    printf ">─"
    set_color normal
  end
end

function prompt_user_hostname_pwd -d "Display user, hostname, and current directory"
  set_color -o blue
  printf "%s " (whoami)
  set_color normal

  set_color $fish_color_autosuggestion[1]
  printf "@ "
  set_color normal

  set_color cyan
  printf "%s " (hostname|cut -d . -f 1)
  set_color normal

  set_color $fish_color_autosuggestion[1]
  printf "in "
  set_color normal

  set_color -o green
  printf "%s" (prompt_pwd)
  set_color normal
end

function prompt_git -d "Display git status"
  if [ (_git_branch_name) ]
    set_color yellow
    printf "("
    set_color normal

    if [ (_is_git_dirty) ]
      set_color -o red
      printf "%s" (_git_branch_name)
      set_color normal

      set_color brblue
      printf "*"
      set_color normal
    else
      set_color -o yellow
      printf "%s" (_git_branch_name)
      set_color normal
    end

    if [ (_is_git_unpushed) ]
      set_color -o brgreen
      printf "↑"
      set_color normal
    end

    if [ (_is_git_unpulled) ]
      set_color -o brcyan
      printf "↓"
      set_color normal
    end

    if [ (_is_git_conflict) ]
      set_color -o brred
      printf "✕"
      set_color normal
    end

    set_color yellow
    printf ")"
    set_color normal

    if [ (_get_git_staged_count) != 0 ]
      set_color -o green
      printf " +%s" (_get_git_staged_count)
      set_color normal
     end

    if [ (_get_git_unstaged_count) != 0 ]
      set_color -o blue
      printf " !%s" (_get_git_unstaged_count)
      set_color normal
    end

    if [ (_get_git_untracked_count) != 0 ]
      set_color -o cyan
      printf " ?%s" (_get_git_untracked_count)
      set_color normal
    end

    if [ (_get_git_stashed_count) != 0 ]
      set_color -o magenta
      printf " *%s" (_get_git_stashed_count)
      set_color normal
    end

    if [ (_get_git_conflict_count) != 0 ]
      set_color -o red
      printf " ~%s" (_get_git_conflict_count)
      set_color normal
    end
  end
end

function fish_default_mode_prompt -d "Display vi mode prompt"
  if [ "$fish_key_bindings" = "fish_default_key_bindings" ]
    return
  end

  printf " "

  switch $fish_bind_mode
    case insert
      set_color -o green
      printf "(I)"
    case visual
      set_color -o magenta
      printf "(V)"
    case replace-one
      set_color -o green
      printf "(R)"
    case default
      set_color -o blue
      printf "(N)"
  end

  set_color normal
end

function fish_prompt -d "define the appearance of the command line prompt"
  set -g VIRTUAL_ENV_DISABLE_PROMPT true

  echo

  set_color -o red
  printf "┌"
  set_color normal

  prompt_proxy

  set_color -o red
  printf "─<"
  set_color normal

  prompt_virtual_env
  prompt_jobs
  prompt_user_hostname_pwd
  fish_default_mode_prompt

  set_color -o red
  printf ">"
  set_color normal

  echo

  set_color -o red
  printf "└─<"
  set_color normal

  prompt_git

  set_color -o red
  printf ">──"
  set_color normal

  set_color yellow
  printf "❯ "
  set_color normal
end
