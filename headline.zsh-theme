#!/bin/zsh

# Headline ZSH Prompt
# Copyright (c) 2022 Moarram under the MIT License

# To install, source this file from your .zshrc file
# Customization variables begin around line 70



# Formatting aliases
# (add more if you need)
reset=$'\e[0m'
bold=$'\e[1m'
faint=$'\e[2m'
italic=$'\e[3m'
underline=$'\e[4m'
invert=$'\e[7m'
# ...

# Foreground color aliases
black=$'\e[30m'
red=$'\e[31m'
green=$'\e[32m'
yellow=$'\e[33m'
blue=$'\e[34m'
magenta=$'\e[35m'
cyan=$'\e[36m'
white=$'\e[37m'
light_black=$'\e[90m'
light_red=$'\e[91m'
light_green=$'\e[92m'
light_yellow=$'\e[93m'
light_blue=$'\e[94m'
light_magenta=$'\e[95m'
light_cyan=$'\e[96m'
light_white=$'\e[97m'

# Background color aliases
black_back=$'\e[40m'
red_back=$'\e[41m'
green_back=$'\e[42m'
yellow_back=$'\e[43m'
blue_back=$'\e[44m'
magenta_back=$'\e[45m'
cyan_back=$'\e[46m'
white_back=$'\e[47m'
light_black_back=$'\e[100m'
light_red_back=$'\e[101m'
light_green_back=$'\e[102m'
light_yellow_back=$'\e[103m'
light_blue_back=$'\e[104m'
light_magenta_back=$'\e[105m'
light_cyan_back=$'\e[106m'
light_white_back=$'\e[107m'

# Custom colors
# REF: https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
# orange_yellow=$'\e[38;5;214m' # example 8-bit color
# orange_brown=$'\e[38;2;191;116;46m' # example rgb color
# ...

# Flags
! [ -z "$SSH_TTY$SSH_CONNECTION$SSH_CLIENT" ]
IS_SSH=$? # 0=true, 1=false



# ------------------------------------------------------------------------------
# Customization
# Use the following variables to customize the theme
# These variables can also be set in your ~/.zshrc after sourcing this file
# The style aliases for ANSI SGR codes (defined above) can be used there too

# Info sources (enclose in single quotes as these will be eval'd, use empty string to hide segment)
HEADLINE_USER_CMD=''
HEADLINE_HOST_CMD='' # consider 'basename "$VIRTUAL_ENV"' to replace host with environment
HEADLINE_PATH_CMD='print -rP "%~"'

# Info symbols (optional)
HEADLINE_USER_PREFIX='' # consider
HEADLINE_HOST_PREFIX='' # consider
HEADLINE_PATH_PREFIX='' # consider

# Info joints
HEADLINE_USER_BEGIN=''
if [ $IS_SSH = 0 ]; then HEADLINE_USER_BEGIN='=> '; fi
HEADLINE_USER_TO_HOST=''
HEADLINE_HOST_TO_PATH=': '
HEADLINE_PATH_TO_BRANCH=' | ' # only used when no padding between <path> and <branch>
HEADLINE_PATH_TO_PAD='' # used if padding between <path> and <branch>
HEADLINE_PAD_TO_BRANCH='' # used if padding between <path> and <branch>
HEADLINE_STATUS_TO_STATUS='' # between each status section, consider "]"
HEADLINE_STATUS_END=']'

# Info padding character
HEADLINE_PAD_CHAR='-' # repeated for space between <path> and <branch>

# Info truncation symbol
HEADLINE_TRUNC_PREFIX='...' # shown where <path> or <branch> is truncated, consider

# Info styles
HEADLINE_STYLE_DEFAULT='' # style applied to entire info line
HEADLINE_STYLE_JOINT=$light_black
HEADLINE_STYLE_USER=$bold$red
HEADLINE_STYLE_HOST=$bold$yellow
HEADLINE_STYLE_PATH=$bold$green
HEADLINE_STYLE_BRANCH=$bold$cyan
HEADLINE_STYLE_STATUS=$bold$magenta

# Info options
HEADLINE_INFO_MODE=precmd # precmd|prompt (whether info line is in PROMPT or printed by precmd)
  # use "precmd" for window resize to work properly (but Ctrl+L doesn't show info line)
  # use "prompt" for Ctrl+L to clear properly (but window resize eats previous output)

# Separator options
HEADLINE_LINE_MODE=off # on|auto|off (whether to print the line above the prompt)

# Separator character
HEADLINE_LINE_CHAR='_' # repeated for line above information

# Separator styles
HEADLINE_STYLE_JOINT_LINE=$HEADLINE_STYLE_JOINT
HEADLINE_STYLE_USER_LINE=$HEADLINE_STYLE_USER
HEADLINE_STYLE_HOST_LINE=$HEADLINE_STYLE_HOST
HEADLINE_STYLE_PATH_LINE=$HEADLINE_STYLE_PATH
HEADLINE_STYLE_BRANCH_LINE=$HEADLINE_STYLE_BRANCH
HEADLINE_STYLE_STATUS_LINE=$HEADLINE_STYLE_STATUS

# Prompt
HEADLINE_PROMPT='%{$cyan%}%(#.#.%(!.!.$))%{$reset%} ' # consider "%#"
HEADLINE_RPROMPT=''

# Clock (prepends to RPROMPT)
HEADLINE_DO_CLOCK=false # whether to show the clock
HEADLINE_STYLE_CLOCK=$faint
HEADLINE_CLOCK_FORMAT='%l:%M:%S %p' # consider "%+" for full date (see man strftime)

# Exit code
HEADLINE_DO_ERR=false # whether to show non-zero exit codes above prompt
HEADLINE_DO_ERR_INFO=true # whether to show exit code meaning as well
HEADLINE_ERR_PREFIX=''
HEADLINE_STYLE_ERR=$italic$faint

# ------------------------------------------------------------------------------



# Options for zsh
setopt PROMPT_SP # always start prompt on new line
setopt PROMPT_SUBST # substitutions
autoload -U add-zsh-hook
PROMPT_EOL_MARK='' # remove weird % symbol
ZLE_RPROMPT_INDENT=0 # remove extra space

# Local variables
_HEADLINE_LINE_OUTPUT='' # separator line
_HEADLINE_INFO_OUTPUT='' # text line
_HEADLINE_DO_SEP='false' # whether to show divider this time
if [ $IS_SSH = 0 ]; then
  _HEADLINE_DO_SEP='true' # assume it's not a fresh window
fi

# Calculate length of string, excluding formatting characters
# REF: https://old.reddit.com/r/zsh/comments/cgbm24/multiline_prompt_the_missing_ingredient/
headline_prompt_len() { # (str, num)
  emulate -L zsh
  local -i COLUMNS=${2:-COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  echo $x
}

# Repeat character a number of times
# (replacing the "${(pl:$num::$char:)}" expansion)
headline_repeat_char() { # (char, num)
  local str=''
  for (( i = 0; i < $2; i++ )); do
    str+=$1
  done
  echo $str
}

# Guess the exit code meaning
headline_exit_meaning() { # (num)
  # REF: https://tldp.org/LDP/abs/html/exitcodes.html
  # REF: https://man7.org/linux/man-pages/man7/signal.7.html
  # NOTE: these meanings are not standardized
  case $1 in
    126) echo 'Command cannot execute';;
    127) echo 'Command not found';;
    129) echo 'Hangup';;
    130) echo 'Interrupted';;
    131) echo 'Quit';;
    132) echo 'Illegal instruction';;
    133) echo 'Trapped';;
    134) echo 'Aborted';;
    135) echo 'Bus error';;
    136) echo 'Arithmetic error';;
    137) echo 'Killed';;
    138) echo 'User signal 1';;
    139) echo 'Segmentation fault';;
    140) echo 'User signal 2';;
    141) echo 'Pipe error';;
    142) echo 'Alarm';;
    143) echo 'Terminated';;
    *) ;;
  esac
}





# Before executing command
add-zsh-hook preexec headline_preexec
headline_preexec() {
  # TODO better way of knowing the prompt is at the top of the terminal
  if [[ $2 == 'clear' ]]; then
    _HEADLINE_DO_SEP='false'
  fi
}

# Before prompting
add-zsh-hook precmd headline_precmd
headline_precmd() {
  local err=$?

  # Information
  local user_str host_str path_str branch_str status_str
  user_str=$(eval $HEADLINE_USER_CMD)
  host_str=$(eval $HEADLINE_HOST_CMD)
  path_str=$(eval $HEADLINE_PATH_CMD)

  # Shared variables
  _HEADLINE_LEN_REMAIN=$COLUMNS
  _HEADLINE_INFO_LEFT=''
  _HEADLINE_LINE_LEFT=''
  _HEADLINE_INFO_RIGHT=''
  _HEADLINE_LINE_RIGHT=''

  # Trimming
  local joint_len=$(( ${#HEADLINE_USER_BEGIN} + ${#HEADLINE_USER_TO_HOST} + ${#HEADLINE_HOST_TO_PATH} + ${#HEADLINE_PATH_TO_BRANCH} ))
  local path_min_len=$(( ${#path_str} + ${#HEADLINE_PATH_PREFIX} > 25 ? 25 : ${#path_str} + ${#HEADLINE_PATH_PREFIX} ))
  len=$(( $_HEADLINE_LEN_REMAIN - $path_min_len - $joint_len ))
  if (( $len < 2 )); then
    user_str=''; host_str=''
  elif (( $len < ${#user_str} + ${#host_str} )); then
    user_str="${user_str:0:1}"
    host_str="${host_str:0:1}"
  fi

  # User
  if (( ${#user_str} )); then
    _headline_part JOINT "$HEADLINE_USER_BEGIN" left
    _headline_part USER "$HEADLINE_USER_PREFIX$user_str" left
  fi

  # Host
  if (( ${#host_str} )); then
    if (( ${#_HEADLINE_INFO_LEFT} )); then
      _headline_part JOINT "$HEADLINE_USER_TO_HOST" left
    fi
    _headline_part HOST "$HEADLINE_HOST_PREFIX$host_str" left
  fi

  # Path
  if (( ${#path_str} )); then
    if (( ${#_HEADLINE_INFO_LEFT} )); then
      _headline_part JOINT "$HEADLINE_HOST_TO_PATH" left
    fi
    len=$(( $_HEADLINE_LEN_REMAIN - ${#HEADLINE_PATH_PREFIX} - ( ${#branch_str} ? ${#HEADLINE_PATH_TO_BRANCH} : 0 ) ))
    _headline_part PATH "$HEADLINE_PATH_PREFIX%$len<$HEADLINE_TRUNC_PREFIX<$path_str%<<" left
  fi

  # Padding
  if (( ${#branch_str} && ${#path_str} && $_HEADLINE_LEN_REMAIN <= ${#HEADLINE_PATH_TO_BRANCH} )); then
    _headline_part JOINT "$HEADLINE_PATH_TO_BRANCH" left
  else
    if (( ${#branch_str} )); then
      _headline_part JOINT "$HEADLINE_PAD_TO_BRANCH" right
    fi
    _headline_part JOINT "$HEADLINE_PATH_TO_PAD" left
    _headline_part JOINT " $(headline_repeat_char $cyan$HEADLINE_PAD_CHAR $((_HEADLINE_LEN_REMAIN - 1)))$reset" left
  fi

  # Error line
  if [[ $HEADLINE_DO_ERR == 'true' ]] && (( $err )); then
    local meaning msg
    if [[ $HEADLINE_DO_ERR_INFO == 'true' ]]; then
      meaning=$(headline_exit_meaning $err)
      (( ${#meaning} )) && msg=" ($meaning)"
    fi
    print -rP "$HEADLINE_STYLE_ERR$HEADLINE_ERR_PREFIX$err$msg"
  fi

  # Separator line
  _HEADLINE_LINE_OUTPUT="$_HEADLINE_LINE_LEFT$_HEADLINE_LINE_RIGHT$reset"
  if [[ $HEADLINE_LINE_MODE == 'on' || ($HEADLINE_LINE_MODE == 'auto' && $_HEADLINE_DO_SEP == 'true' ) ]]; then
    print -rP $_HEADLINE_LINE_OUTPUT
  fi
  _HEADLINE_DO_SEP='true'

  # Information line
  _HEADLINE_INFO_OUTPUT="$_HEADLINE_INFO_LEFT$_HEADLINE_INFO_RIGHT$reset"

  # Prompt
  if [[ $HEADLINE_INFO_MODE == 'precmd' ]]; then
    print -rP $_HEADLINE_INFO_OUTPUT
    PROMPT=$HEADLINE_PROMPT
  else
    PROMPT='$(print -rP $_HEADLINE_INFO_OUTPUT; print -rP $HEADLINE_PROMPT)'
  fi

  # Right prompt
  if [[ $HEADLINE_DO_CLOCK == 'true' ]]; then
    RPROMPT='%{$HEADLINE_STYLE_CLOCK%}$(date +$HEADLINE_CLOCK_FORMAT)%{$reset%}$HEADLINE_RPROMPT'
  else
    RPROMPT=$HEADLINE_RPROMPT
  fi
}

# Create a part of the prompt
_headline_part() { # (name, content, side)
  local style info info_len line
  eval style="\$reset\$HEADLINE_STYLE_DEFAULT\$HEADLINE_STYLE_${1}"
  info="%{$style%}$2"
  info_len=$(headline_prompt_len $info 9999)
  _HEADLINE_LEN_REMAIN=$(( $_HEADLINE_LEN_REMAIN - $info_len ))
  eval style="\$reset\$HEADLINE_STYLE_${1}_LINE"
  line="%{$style%}$(headline_repeat_char $HEADLINE_LINE_CHAR $info_len)"
  if [[ $3 == 'right' ]]; then
    _HEADLINE_INFO_RIGHT="$info$_HEADLINE_INFO_RIGHT"
    _HEADLINE_LINE_RIGHT="$line$_HEADLINE_LINE_RIGHT"
  else
    _HEADLINE_INFO_LEFT="$_HEADLINE_INFO_LEFT$info"
    _HEADLINE_LINE_LEFT="$_HEADLINE_LINE_LEFT$line"
  fi
}