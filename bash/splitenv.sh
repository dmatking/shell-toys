#!/usr/bin/env bash

YELLOW='\e[93m'
RESET='\e[0m'

if [[ -z "$1" ]]; then
    echo "Usage: $(basename "$0") ENV_VARIABLE_NAME [SEARCH_WORD]"
    exit 1
fi

var_name="$1"
search="$2"
var_value="${!var_name}"

if [[ -z "$var_value" ]]; then
    echo "The environment variable '$var_name' is empty or does not exist."
    exit 1
fi

n=0
while IFS= read -r entry; do
    ((n++))
    if [[ -z "$entry" ]]; then
        [[ -z "$search" ]] && echo -e "${YELLOW}[$n] [Consecutive colons detected.]${RESET}"
    elif [[ -z "$search" ]] || grep -qi "$search" <<< "$entry"; then
        echo "[$n] $entry"
    fi
done < <(tr ':' '\n' <<< "$var_value")
