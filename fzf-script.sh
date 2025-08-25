#!/usr/bin/env bash
sel=$(
  eza --recurse -1 --absolute --icons=always -d \
    | grep -vE '(^$|:$)' \
    | fzf \
    | cut -c2- \
    | tr -d '[:space:]' \
    | iconv -c
)

if [ -d "$sel" ]; then
    printf '%s\n' "$sel"
else
    dirname -- "$sel"
fi

