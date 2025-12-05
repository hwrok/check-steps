#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

source "$(dirname "$0")/comments.sh"

failures=()
successes=()
comment=""
padded_length=0

while IFS='|' read -r name outcome; do
  [ -z "$name" ] && continue

  name_length=${#name}
  [ "$name_length" -gt "$padded_length" ] && padded_length=$name_length

  if [ "$outcome" = "success" ]; then
    successes+=("$name:$outcome")
  else
    failures+=("$name:$outcome")
  fi
done <<< "$INPUT_STEPS"

print_status() {
  local desc="$1"
  local outcome="$2"
  local padded_name

  padded_name=$(printf "%-${padded_length}s" "$desc")
  case "$outcome" in
    success) echo -e "    ${padded_name} : ${GREEN}${outcome}${RESET}" ;;
    failure) echo -e "    ${padded_name} : ${RED}${outcome}${RESET}" ;;
    *) echo -e "    ${padded_name} : ${YELLOW}${outcome}${RESET}" ;;
  esac
}

echo ""
if [ ${#failures[@]} -gt 0 ] && [ ${#successes[@]} -eq 0 ]; then
  comment="${all_failed[$RANDOM % ${#all_failed[@]}]}"
  echo -e "${RED}${comment}${RESET}"
elif [ ${#failures[@]} -gt 0 ]; then
  comment="${partial_failed[$RANDOM % ${#partial_failed[@]}]}"
  echo -e "${RED}${comment}${RESET}"
elif [ ${#successes[@]} -gt 0 ] && [ ${#failures[@]} -eq 0 ]; then
  comment="${all_success[$RANDOM % ${#all_success[@]}]}"
  echo -e "${GREEN}${comment}${RESET}"
fi
echo ""

if [ ${#failures[@]} -gt 0 ]; then
  echo -e "${RED}refer to the failing step(s) for more information...${RESET}"
  echo ""

  title="FAILURE"
  bar_len=$(( ${#title} + 2 ))

  echo -e "${RED}┌$(printf '─%.0s' $(seq 1 $bar_len))┐${RESET}"
  echo -e "${RED}│ ${title} │${RESET}"
  echo -e "${RED}└$(printf '─%.0s' $(seq 1 $bar_len))┘${RESET}"

  for step in "${failures[@]}"; do
    IFS=':' read -r desc outcome <<< "$step"
    print_status "$desc" "$outcome"
  done
  echo ""
fi

if [ ${#successes[@]} -gt 0 ]; then
  title="SUCCESS"
  bar_len=$(( ${#title} + 2 ))

  echo -e "${GREEN}┌$(printf '─%.0s' $(seq 1 $bar_len))┐${RESET}"
  echo -e "${GREEN}│ ${title} │${RESET}"
  echo -e "${GREEN}└$(printf '─%.0s' $(seq 1 $bar_len))┘${RESET}"

  for step in "${successes[@]}"; do
    IFS=':' read -r desc outcome <<< "$step"
    print_status "$desc" "$outcome"
  done
  echo ""
fi

if [ ${#failures[@]} -gt 0 ]; then
  echo "failed=true" >> "$GITHUB_OUTPUT"
  exit 1
else
  echo "failed=false" >> "$GITHUB_OUTPUT"
fi
