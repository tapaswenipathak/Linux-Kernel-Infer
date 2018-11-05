#!/usr/bin/env bash

NAME='Bootloader'
VERSION='1.0.0'

OPTION_HELP='h'
OPTION_LOAD_KERNEL='l'
OPTION_VERSION='v'
ALL_OPTIONS="$OPTION_HELP$OPTION_LOAD_KERNEL$OPTION_LOAD_KERNEL"

DESCRIPTION_HELP="Print the help of package $NAME"
DESCRIPTION_LOAD_KERNEL='Load a new kernel'
DESCRIPTION_VERSION="Print the version of $NAME"

declare -A BOOT_ENTRIES
BOOT_ENTRIES_LAST_INDEX=-1
SELECTED_BOOT_ENTRY_INDEX=-1

help() {
  local PACKAGE_LOCATION=`basename "$0"`

  /usr/bin/printf '%s %s\n' "$NAME" "$VERSION"
  /usr/bin/printf 'Usage: %s [OPTION]\n\n' "$PACKAGE_LOCATION"

  /usr/bin/printf ' -%s\t%s\n' \
    "$OPTION_HELP" "$DESCRIPTION_HELP" \
    "$OPTION_LOAD_KERNEL" "$DESCRIPTION_LOAD_KERNEL"
    "$OPTION_VERSION" "$DESCRIPTION_VERSION" \

  exit
}

version() {
  /usr/bin/printf '%s %s\n' "$NAME" "$VERSION"
  exit
}

checkIfNotRoot() {
  if [[ `id -u` != '0' ]]; then
    /usr/bin/printf '%s requires to be run as root. Exiting...\n' "$NAME"
    exit 13
  fi
}

getBootEntries() {
  local NON_LINUX_INDICES=0;
  local LAST_INDEX=-1;

  while read -r LINE; do
    local ARGS=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^args="(.+)"$/\1/p'`
    local INDEX=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^index=(.+)$/\1/p'`
    local INITRD=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^initrd=(.+)$/\1/p'`
    local KERNEL=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^kernel=(.+)$/\1/p'`
    local NON_LINUX_ENTRY=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^(non linux entry)$/\1/p'`
    local ROOT=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^root=(.+)$/\1/p'`
    local TITLE=`/usr/bin/printf '%s\n' "$LINE" | sed -nE 's/^title=(.+)$/\1/p'`

    if [[ -n "$INDEX" ]]; then
      LAST_INDEX="$INDEX"
      BOOT_ENTRIES["$LAST_INDEX,INDEX"]="$INDEX"
    fi

    [[ -n "$ARGS" ]] && BOOT_ENTRIES["$LAST_INDEX,ARGS"]="$ARGS"
    [[ -n "$INITRD" ]] && BOOT_ENTRIES["$LAST_INDEX,INITRD"]="$INITRD"
    [[ -n "$KERNEL" ]] && BOOT_ENTRIES["$LAST_INDEX,KERNEL"]="$KERNEL"
    [[ -n "$ROOT" ]] && BOOT_ENTRIES["$LAST_INDEX,ROOT"]="$ROOT"
    [[ -n "$TITLE" ]] && BOOT_ENTRIES["$LAST_INDEX,TITLE"]="$TITLE"

    if [[ -n "$NON_LINUX_ENTRY" ]]; then
      let "NON_LINUX_INDICES=$NON_LINUX_INDICES + 1"
      unset BOOT_ENTRIES["$LAST_INDEX,INDEX"]
    fi
  done <<< `grubby --info=ALL`

  let "BOOT_ENTRIES_LAST_INDEX=LAST_INDEX - NON_LINUX_INDICES"
}

printBootEntries() {
  /usr/bin/printf ' %s \t %s \n' "INDEX" "KERNEL"

  local CURRENT_INDEX=0
  while [[ "$CURRENT_INDEX" -le "$BOOT_ENTRIES_LAST_INDEX" ]]; do
    /usr/bin/printf ' %s \t %s \n' "$CURRENT_INDEX" "${BOOT_ENTRIES[$CURRENT_INDEX,TITLE]}"
    let "CURRENT_INDEX=$CURRENT_INDEX + 1"
  done
}

selectBootEntry() {
  while [[ ( ! "$SELECTED_BOOT_ENTRY_INDEX" =~ ^[0-9]+$ ) || ( "$SELECTED_BOOT_ENTRY_INDEX" -lt '0' ) || ( "$SELECTED_BOOT_ENTRY_INDEX" -gt "$BOOT_ENTRIES_LAST_INDEX" ) ]]; do
    /usr/bin/printf 'Please select a boot entry (0 - %s): ' "$BOOT_ENTRIES_LAST_INDEX"
    read SELECTED_BOOT_ENTRY_INDEX
  done
}

unloadPreviousKernel() {
  kexec -u
  /usr/bin/printf 'Unloaded any previously loaded kernel.\n'
}

loadKernel() {
  local ARGS="${BOOT_ENTRIES[$SELECTED_BOOT_ENTRY_INDEX,ARGS]}"
  local INITRD="${BOOT_ENTRIES[$SELECTED_BOOT_ENTRY_INDEX,INITRD]}"
  local KERNEL="${BOOT_ENTRIES[$SELECTED_BOOT_ENTRY_INDEX,KERNEL]}"
  local ROOT="${BOOT_ENTRIES[$SELECTED_BOOT_ENTRY_INDEX,ROOT]}"
  local TITLE="${BOOT_ENTRIES[$SELECTED_BOOT_ENTRY_INDEX,TITLE]}"

  kexec -l "$KERNEL" --initrd="$INITRD" --append="root=$ROOT $ARGS"
  /usr/bin/printf 'Loaded %s.\n' "$TITLE"
}

[[ -z "$1" ]] && help

while getopts "$ALL_OPTIONS" OPTION; do
  case "$OPTION" in
    "$OPTION_HELP")
      help
      ;;
   "$OPTION_LOAD_KERNEL")
      exitIfNotRoot
      getBootEntries
      printBootEntries
      selectBootEntry
      unloadPreviousKernel
      loadKernel
      ;;
   "$OPTION_VERSION")
      version
      ;;
    *)
      help
      ;;
  esac
done
