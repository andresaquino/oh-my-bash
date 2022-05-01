#! bash oh-my-bash.module

# ------------------------------------------------------------------
#  FILE: macuarra-theme
#  BY: Andres Aquino
#  BASED ON: Cooperkid && binaryanomaly
# ------------------------------------------------------------------

# hostname color
function get_host() {
    local address="\h"
    local color="${yellow}"

    [[ -n "${NET_ADDRESS}" ]] && address="${NET_ADDRESS}"
    [[ -n "${SSH_CLIENT}" ]] && color="${red}"
    echo "${color}${address}${reset_color}"
}

# username color
function get_user() {
    local iduser="$(id -u)"
    local color="${blue}"

    [ 0 -eq "${iduser}" ] && color="${red}"
    echo "${color}\u${reset_color}"
}

# datetime string in a simple format
function get_timestamp() {
    echo "${white}$(date '+%Y%m%d')${gray}|${white}$(date '+%H%M')${reset_color}"
}

# branch status
function get_branch() {
    # head
    git rev-parse --short HEAD >| "${BRANCH_HEAD}" 2>/dev/null

    # status
    [[ ! -s "${BRANCH_HEAD}" ]] && return

    # info
    git status --branch >| "${BRANCH_INFO}" 2>/dev/null

    # status & name
    local SHA16=$(cat "${BRANCH_HEAD}")
    local STATUS="${green}${reset_color}"
    local BRANCH=$(sed -n 's/On branch \(\w*\)/\1/p' "${BRANCH_INFO}")

    # untraked?
    local UNTRACKED=$(sed -n 's/\(Untracked\) files/\1/p' "${BRANCH_INFO}")
    [[ -n "${UNTRACKED}" ]] && STATUS="${yellow}${reset_color}"

    # not staged?
    local UNSTAGED=$(sed -n 's/\(not staged\) for commit/\1/p' "${BRANCH_INFO}")
    [[ -n "${UNSTAGED}" ]] && STATUS="${red}${reset_color}"

    # to be committed
    local TOBECOMMITED=$(sed -n 's/Changes \(to be committed\)/\1/p' "${BRANCH_INFO}")
    [[ -n "${UNSTAGED}" ]] && STATUS="${cyan}${reset_color}"

    #
    echo "${reset_color} ${BRANCH} [${purple}${SHA16}${reset_color}] ${STATUS}"
}

#
function _omb_theme_PROMPT_COMMAND() {
    local ps_header="${reset_color}$(get_user)@$(get_host) ${bold_yellow}\w${reset_color}"
    local ps_prompt="$(get_timestamp)$(get_branch) \$${reset_color}"

    PS1="\n${ps_header}\n${ps_prompt} "
}

#
export BRANCH_HEAD=$(mktemp -qt ${TERM_SESSION_ID/*-/}-head)
export BRANCH_INFO=$(mktemp -qt ${TERM_SESSION_ID/*-/}-branch)
export NET_INTERFACE=$(route get default 2>/dev/null | sed -n 's/.*interface: \([0-9.]*\)/\1/p')
export NET_ADDRESS=$(ipconfig getifaddr "${NET_INTERFACE}")

#
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
