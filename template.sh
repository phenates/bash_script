#!/usr/bin/env bash
#
# Phenates; v0.1
# Script purpose....

#Variables:

#######################################
# Show script usage.
# Arguments: Options (h,i,r)
# Outputs: None
#######################################
usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo "Options:"
  echo "  -h, --help: Display usage"
}

#######################################
# Function.
# Arguments: None
# Outputs: None
#######################################
sudo_ceck() {
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
