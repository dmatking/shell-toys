#!/usr/bin/env bash

YELLOW='\e[33m'
BLUE='\e[34m'
GREEN='\e[32m'
MAGENTA='\e[35m'
RESET='\e[0m'

is_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
}

parse_config() {
    local scope=$1
    local -n _out=$2
    local output
    output=$(git config "--$scope" -l 2>/dev/null) || return
    while IFS= read -r line; do
        local key="${line%%=*}"
        local value="${line#*=}"
        _out["$key"]="$value"
    done <<< "$output"
}

print_config() {
    local title=$1 color=$2
    local -n _cfg=$3
    echo -e "${color}${title} Configuration:${RESET}"
    if [[ ${#_cfg[@]} -eq 0 ]]; then
        echo "    (empty)"
    else
        for key in $(printf '%s\n' "${!_cfg[@]}" | sort); do
            echo "    $key = ${_cfg[$key]}"
        done
    fi
    echo
}

override=false
[[ "$1" == "--override" ]] && override=true

if ! $override && ! is_git_repo; then
    echo "Not inside a Git repository. Use --override to run anyway."
    exit 1
fi

declare -A system_cfg global_cfg local_cfg
parse_config system system_cfg
parse_config global global_cfg
parse_config local  local_cfg

print_config "System" "$YELLOW" system_cfg
print_config "Global" "$BLUE"   global_cfg
print_config "Local"  "$GREEN"  local_cfg

# Effective config: local beats global beats system
declare -A eff_val eff_src

for key in "${!system_cfg[@]}"; do eff_val["$key"]="${system_cfg[$key]}"; eff_src["$key"]="system"; done
for key in "${!global_cfg[@]}"; do eff_val["$key"]="${global_cfg[$key]}"; eff_src["$key"]="global"; done
for key in "${!local_cfg[@]}";  do eff_val["$key"]="${local_cfg[$key]}";  eff_src["$key"]="local";  done

echo -e "${MAGENTA}Effective Configuration:${RESET}  ${YELLOW}■ system${RESET}  ${BLUE}■ global${RESET}  ${GREEN}■ local${RESET}"
echo

for key in $(printf '%s\n' "${!eff_val[@]}" | sort); do
    case "${eff_src[$key]}" in
        system) color="$YELLOW" ;;
        global) color="$BLUE"   ;;
        local)  color="$GREEN"  ;;
    esac
    echo -e "    ${color}${key}: ${eff_val[$key]}${RESET}"
done
