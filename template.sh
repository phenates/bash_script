#!/usr/bin/env bash
#
# Phenates; v0.1
# Script purpose....

#Variables:
PURPOSE=""
NOCOLOR='\033[0m'
BLUE='\033[0;34m'
RED='\033[0;31m'

#######################################
# Show script usage.
# Arguments: Options (h,i,r)
# Outputs: None
#######################################
usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo "Purpose: $PURPOSE"
  echo "Options:"
  echo "  -h, --help: Display usage"
}

#######################################
# Header start & end script.
# Arguments: "start" or "end"
# Outputs: None
#######################################
header() {
  case $1 in
  "start")
    echo ""
    echo ""
    echo -e "$BLUE//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "$BLUE////////// $(basename "$0") started... \\\\\\\\\\"
    ;;
  "end")
    echo -e "$BLUE\\\\\\\\\\ $(basename "$0") finished... //////////"
    echo -e "$BLUE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////"
    echo ""
    echo ""
    ;;
  esac
}

#######################################
# Function.
# Arguments: None
# Outputs: None
#######################################
my_function() {
  return 0
}

#######################################
# Main function.
# Arguments: None
# Outputs: None
#######################################
main() {
  case "$1" in
  -h | --help)
    usage
    ;;

  *)
    usage
    ;;
  esac
}
main "$*"
