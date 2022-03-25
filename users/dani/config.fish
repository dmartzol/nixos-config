#-------------------------------------------------------------------------------
# SSH Agent
#-------------------------------------------------------------------------------
function __ssh_agent_is_started -d "check if ssh agent is already started"
	if begin; test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"; end
		source $SSH_ENV > /dev/null
	end

	if test -z "$SSH_AGENT_PID"
		return 1
	end

	ssh-add -l > /dev/null 2>&1
	if test $status -eq 2
		return 1
	end
end

function __ssh_agent_start -d "start a new ssh agent"
  ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
  chmod 600 $SSH_ENV
  source $SSH_ENV > /dev/null
  ssh-add
end

if not test -d $HOME/.ssh
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
end

if test -d $HOME/.gnupg
    chmod 0700 $HOME/.gnupg
end

if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

if not __ssh_agent_is_started
    __ssh_agent_start
end

#-------------------------------------------------------------------------------
# Kitty Shell Integration
#-------------------------------------------------------------------------------
if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

#-------------------------------------------------------------------------------
# Vim
#-------------------------------------------------------------------------------
# We should move this somewhere else but it works for now
mkdir -p $HOME/.vim/{backup,swap,undo}

#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------
# Do not show any greeting
set --universal --erase fish_greeting
function fish_greeting; end
funcsave fish_greeting

# bobthefish theme
set -g theme_color_scheme dracula

# My color scheme
set -U fish_color_normal normal
set -U fish_color_command F8F8F2
set -U fish_color_quote F1FA8C
set -U fish_color_redirection 8BE9FD
set -U fish_color_end 50FA7B
set -U fish_color_error FF5555
set -U fish_color_param 5FFFFF
set -U fish_color_comment 6272A4
set -U fish_color_match --background=brblue
set -U fish_color_selection white --bold --background=brblack
set -U fish_color_search_match bryellow --background=brblack
set -U fish_color_history_current --bold
set -U fish_color_operator 00a6b2
set -U fish_color_escape 00a6b2
set -U fish_color_cwd green
set -U fish_color_cwd_root red
set -U fish_color_valid_path --underline
set -U fish_color_autosuggestion BD93F9
set -U fish_color_user brgreen
set -U fish_color_host normal
set -U fish_color_cancel -r
set -U fish_pager_color_completion normal
set -U fish_pager_color_description B3A06D yellow
set -U fish_pager_color_prefix white --bold --underline
set -U fish_pager_color_progress brwhite --background=cyan

# Override the nix prompt for the theme so that we show a more concise prompt
function __bobthefish_prompt_nix -S -d 'Display current nix environment'
    [ "$theme_display_nix" = 'no' -o -z "$IN_NIX_SHELL" ]
    and return

    __bobthefish_start_segment $color_nix
    echo -ns N ' '

    set_color normal
end

#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------
# Modify our path to include our Go binaries
contains $HOME/code/go/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/code/go/bin
contains $HOME/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/bin

# Exported variables
if isatty
    set -x GPG_TTY (tty)
end

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
# Shortcut to setup a nix-shell with fish. This lets you do something like
# `fnix -p go` to get an environment with Go but use the fish shell along
# with it.
alias fnix "nix-shell --run fish"

if test -e /Applications/Postgres.app/Contents/Versions/latest/bin/psql
    fish_add_path /Applications/Postgres.app/Contents/Versions/latest/bin/psql
end
if test -d ~/.cargo/bin
    fish_add_path ~/.cargo/bin
end
if test -d ~/go/bin
    fish_add_path ~/go/bin
end
if command -v bat > /dev/null
    abbr --add --global cat bat
end

### Abbreviations ###
abbr --add --global gs git status
abbr --add --global gd git diff
abbr --add --global gco git checkout
abbr --add --global gsl git stash list
abbr --add --global gsa git stash apply
abbr --add --global 'main' 'git checkout main'
abbr --add --global 'master' 'git checkout master'
abbr --add --global 'qa' 'git checkout qa'
abbr --add --global 'commit' 'git commit -m'
abbr --add --global add git add --all
abbr --add --global push git push origin head
abbr --add --global 'dps' 'docker ps'
abbr --add --global 'dpsa' 'docker ps -a'
abbr --add --global gt gotest ./...
abbr --add --global 'cr' 'time cargo run src/main.rs'
abbr --add --global 'cb' 'time cargo build'
abbr --add --global 'dcu' 'docker compose up -d'
abbr --add --global 'dcub' 'docker compose up -d --build'
abbr --add --global unset set --erase
abbr --add --global n 'nvim'
abbr --add --global f 'open .'
abbr --add --global pull git pull
abbr --add --global 'gl' 'git branch --sort=committerdate | head -n 10'
abbr --add --global 'c' 'code .'
abbr --add --global 'reload' '. ~/.config/fish/config.fish'
abbr --add --global 'issue' 'open https://github.com/dmartzol/hmm/issues/'
abbr --add --global 'gci' 'golangci-lint run ./... --print-issued-lines=false --max-same-issues=0 --max-issues-per-linter=0'
abbr --add --global 'caffeinate' 'tmux new-session -d -s caffeinate \'caffeinate\''
abbr --add --global 'decaf' 'tmux kill-session -t caffeinate'
abbr --add --global 'tree' 'exa -aT'

function gb
  time go build -o /dev/null ./...
  time golangci-lint run --new --timeout 2m ./...
  golangci-lint run ./... --print-issued-lines=false --max-same-issues=0 --max-issues-per-linter=0 | wc -l
end

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Changing "ls" to "exa"
if command -v exa > /dev/null
    alias ls='exa -la --no-permissions --group-directories-first'
    alias lt='exa -laT --no-permissions --group-directories-first'
    alias l.='exa -a | egrep "^\."'
end

# Replacing grep with rg
if command -v rg > /dev/null
    abbr --add --global 'grep' 'rg --fixed-strings'
end

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -iv"
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation

#-------------------------------
# NAVI AS WIDGET(CTRL+G)
#-------------------------------
if command -v navi > /dev/null
    navi widget fish | source
end

#-------------------------------
# RICK ROLL
#-------------------------------
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
