#! bash oh-my-bash.module

# ------------------------------------------------------------------
#  FILE: macuarra-theme
#  BY: Andres Aquino
#  BASED ON: Cooperkid && binaryanomaly
# ------------------------------------------------------------------

# hostname color
function get_host() {
    local hostcolor="${bold_red}"
    [[ -z "${SSH_CLIENT}" ]] && hostcolor="${bold_purple}"

    echo "${hostcolor}\h${reset_color} "
}

# username color
function get_user() {
    local usercolor="${blue}"
    [[ 0 -eq $(id -u) ]] && usercolor="${red}"

    echo "${usercolor}\u${reset_color} "
}

# datetime string in a simple format
function get_timestamp() {
    echo "${gray}$(date '+%Y%m%d.%H%M')${reset_color}"
}

# branch status
function get_branch() {
    local status="${green}${reset_color}"
    local shaId=$(git rev-parse --short HEAD 2> /dev/null)

    # git branch ?
    [ -z "${shaId}" ] && return

    # pending to commit ?
    [ "$(git status -s 2>/dev/null)" ] && status="${yellow}${reset_color}"

    # untracked files ?
    [ "$(git status -s 2>/dev/null | grep '??')" ] && status="${red}${reset_color}"

    #
    echo "${reset_color} $(git_current_branch) [${cyan}${shaId}${reset_color}] ${status}"
}

#
function _omb_theme_PROMPT_COMMAND() {
    local ps_header="${reset_color}@$(get_host)${bold_yellow}\w ${reset_color}"
    local ps_prompt="$(get_timestamp)$(get_branch) $(get_user)\$${reset_color}"

    PS1="\n${ps_header}\n${ps_prompt} "
}

# Set term to 256color mode, if 256color is not supported, colors won't work properly
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
  export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
  export TERM=xterm-256color
fi

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
