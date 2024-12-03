#!/usr/bin/env bash

if [[ -z ${SESSION} ]]; then
  echo "SESSION must be set"
  exit 1
fi

MONTH=$(date +"%-m")
if [[ ${MONTH} -ne 12 ]]; then
  echo "You gotta wait until December"
  exit 1
fi

DAY=$(date +"%-d")
PREVIOUS_DAY=$((DAY-1))
BASEPATH="./src/day${DAY}"

if [[ -d "${BASEPATH}" ]] && [[ -f "${BASEPATH}/root.zig" ]]; then
  echo "Day already scaffolded"
  exit 0
fi

set -xe
sed -i "" "\$s?}\$?    try printBox(\"DAY ${DAY}\", @import(\"day${DAY}/root.zig\"));\n}?" ./src/main.zig

mkdir "${BASEPATH}"
cp tmpl.zig "${BASEPATH}/root.zig"

curl -so "${BASEPATH}/input.txt" \
  --cookie session="${SESSION}" \
  "https://adventofcode.com/2024/day/${DAY}/input"
