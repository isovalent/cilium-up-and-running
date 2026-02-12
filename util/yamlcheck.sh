#!/usr/bin/env bash
set -uo pipefail

yamlcheck () {
  local y="$1"
  printf "File: %s\n" "$y"
  yq "$y" >/dev/null
}

ret=0
for y in "$@"
do
  if ! yamlcheck "$y"; then
    ret=-1
  fi
done

exit $ret

