#!/usr/bin/env bash
set -eu # StrictMode, e:exit on non-zero status code; u:prevent undefined variable

## Usage display:
#/ Usage:
#/ Description:
#/ Examples:
#/ Options:
#/   --help: Display this help message
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}
expr "$*" : ".*--help" >/dev/null && usage

## Variables:
SCRIPT_NAME=$(basename "$0")
ARG_1=${1:-"default"}

## Log (add "| tee -a "$LOG_FILE" >&2" to into a file):
readonly LOG_FILE="/tmp/$(basename "$0").log"
info() { echo -e "\033[0;34m[INFO]    $*"; }
warning() { echo -e "[WARNING] $*"; }
error() { echo -e "\033[0;31m[ERROR]   $*"; }

## Functions:
my_function() {
  return 0
}

## Main
main() {
  case "$ARG_1" in
  -h | --help)
    # Script goes here
    ;;

  *)
    usage
    ;;
  esac
}
main "$*"
