#! bash oh-my-bash.module

# ------------------------------------------------------------------
#  FILE: macuarra-theme
#  BY: Andres Aquino
#  BASED ON: Cooperkid && binaryanomaly
# ------------------------------------------------------------------

# hostname color
function get_host() {
    local defcolor="${bold_red}"

    [ -z "${SSH_CLIENT}" ] && defcolor="${bold_purple}"
    echo "${defcolor}\h${reset_color} "
}

# username color
function get_user() {
    local defcolor="${blue}"

    [ 0 -eq $(id -u) ] && defcolor="${red}"
    echo "${defcolor}\u${reset_color} "
}

# datetime string in a simple format
function get_timestamp() {
    echo "${gray}$(date '+%Y%m%d.%H%M')${reset_color}"
}

# get branch information
function get_git_status() {
    # head
    git rev-parse --short HEAD >| "${BRANCH_HEAD}" 2>/dev/null

    # status
    [[ ! -s "${BRANCH_HEAD}" ]] && return

    # info
    git status --branch >| "${BRANCH_INFO}" 2>/dev/null
}

# branch status
function get_branch() {
    local STATUS=""
    local BRANCH=""
    local SHA16=""

    # head
    git rev-parse --short HEAD >| "${BRANCH_HEAD}" 2>/dev/null

    # status
    [[ ! -s "${BRANCH_HEAD}" ]] && return

    # info
    git status --branch >| "${BRANCH_INFO}" 2>/dev/null

    # git branch ?
    STATUS="${green}${reset_color}"
    SHA16=$(cat "${BRANCH_HEAD}")

    # branch name?
    BRANCH=$(sed -n 's/On branch \(\w*\)/\1/p' "${BRANCH_INFO}")

    # pending to commit ?
    UNTRACKED=$(sed -n 's/\(Untracked\) files/\1/p' "${BRANCH_INFO}")
    [[ -n "${UNTRACKED}" ]] && STATUS="${yellow}${reset_color}"

    # untracked files ?
    UNSTAGED=$(sed -n 's/\(not staged\) for commit/\1/p' "${BRANCH_INFO}")
    [[ -n "${UNSTAGED}" ]] && STATUS="${red}${reset_color}"

    #
    echo "${reset_color} ${BRANCH} [${cyan}${SHA16}${reset_color}] ${STATUS}"
}

#
function prompt() {
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

export BRANCH_HEAD="/tmp/${TERM_SESSION_ID/*-/}.head"
export BRANCH_INFO="/tmp/${TERM_SESSION_ID/*-/}.branch"

_omb_util_add_prompt_command prompt
