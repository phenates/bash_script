#!/usr/bin/env bash
set -eu # StrictMode, e:exit on non-zero status code; u:prevent undefined variable

## Usage display:
#/ Usage: This script is a tool to make IP calculation.
#/ Description: Option 1: calculates and displays network information based on a given IP address and subnet mask.
#/ It performs the following tasks:
#/  1. Validates the IP address and subnet mask.
#/  2. Converts the IP address to a decimal number.
#/  3. Calculates the network address, broadcast address, network range, and number of possible hosts.
#/  4. Displays the results in a formatted table.
#/ Examples:
#/ Parameters:
#/ - IP Address: A valid IPv4 address in the format x.x.x.x (e.g., 192.168.1.1).
#/ - Subnet Mask: A number between 0 and 32 representing the subnet mask (e.g., 24).
usage() {
  grep '^#/' "$0" | cut -c4-
  exit 0
}
expr "$*" : ".*--help" >/dev/null && usage

## Variables:
# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

## Functions:
# Function to convert an IP address to a decimal number
ip_to_decimal() {
  local ip=$1
  local IFS=.
  local -a octets=($ip)

  echo $((octets[0] * 256 ** 3 + octets[1] * 256 ** 2 + octets[2] * 256 + octets[3]))
}

# Function to convert a decimal number to an IP address
decimal_to_ip() {
  local decimal=$1
  local ip=""
  for i in {3..0}; do
    local octet=$((decimal / (256 ** i)))
    decimal=$((decimal % (256 ** i)))
    ip+="${octet}."
  done
  echo "${ip%?}"
}

# Function to validate an IP address
validate_ip() {
  local ip=$1
  local IFS=.
  local -a octets=($ip)

  # Check that the IP address has 4 octets
  if [ ${#octets[@]} -ne 4 ]; then
    echo -e "${RED}Error: Invalid IP address. It must contain 4 octets.${NC}"
    return 1
  fi

  # Check that each octet is a number between 0 and 255
  for octet in "${octets[@]}"; do
    if ! [[ $octet =~ ^[0-9]+$ ]] || [ $octet -lt 0 ] || [ $octet -gt 255 ]; then
      echo -e "${RED}Error: Invalid IP address. Each octet must be a number between 0 and 255.${NC}"
      return 1
    fi
  done
}

# Function to calculate network information
calculate_network_info() {
  read -p "Enter the IP address (e.g., 192.168.1.1): " ip_address
  read -p "Enter the subnet mask (e.g., 24): " subnet_mask

  # Validate the IP address
  validate_ip $ip_address
  if [ $? -ne 0 ]; then
    return 1
  fi

  # Validate the subnet mask
  if ! [[ $subnet_mask =~ ^[0-9]+$ ]] || [ $subnet_mask -lt 0 ] || [ $subnet_mask -gt 32 ]; then
    echo -e "${RED}Error: Invalid subnet mask. It must be a number between 0 and 32.${NC}"
    return 1
  fi

  # Convert the IP address to a decimal number
  ip_decimal=$(ip_to_decimal $ip_address)

  # Calculate the subnet mask in decimal
  subnet_decimal=$((0xFFFFFFFF << (32 - subnet_mask) & 0xFFFFFFFF))

  # Calculate the network address
  network_address=$((ip_decimal & subnet_decimal))

  # Calculate the broadcast address
  broadcast_address=$((network_address | ~subnet_decimal & 0xFFFFFFFF))

  # Calculate the start and end of the network range
  range_start=$((network_address + 1))
  range_end=$((broadcast_address - 1))

  # Calculate the number of possible hosts
  hosts_count=$((range_end - range_start + 1))

  # Calculate the inverse network mask
  inverse_mask=$((~subnet_decimal & 0xFFFFFFFF))

  # Display the results in a table format
  echo -e "${GREEN}"
  printf "+-----------------Parameters:-------------------------+\n"
  printf "| %-25s %-20s\n" "IP Address" "$ip_address"
  printf "| %-25s %-20s\n" "Mask" "/$subnet_mask"
  printf "+-------------------Network:--------------------------+\n"
  printf "| %-25s %-20s\n" "Network Address" "$(decimal_to_ip $network_address)"
  printf "| %-25s %-20s\n" "Network Mask (decimal)" "$(decimal_to_ip $subnet_decimal)"
  printf "| %-25s %-20s\n" "Wildcard Mask" "$(decimal_to_ip $inverse_mask)"
  printf "| %-25s %-20s\n" "Host Address Range" "$(decimal_to_ip $range_start) - $(decimal_to_ip $range_end)"
  printf "| %-25s %-20s\n" "Host Number" "$hosts_count"
  printf "| %-25s %-20s\n" "Broadcast Address" "$(decimal_to_ip $broadcast_address)"
  printf "+-----------------------------------------------------+\n"
  echo -e "${NC}"
}

# Main menu
while true; do
  echo "Select an option:"
  echo "1. Calculate network information"
  echo "2. Quit"
  read -p "Your choice: " choice

  case $choice in
  1)
    calculate_network_info
    if [ $? -eq 0 ]; then
      exit 0
    else
      echo -e "${RED}Error calculating network information. Please try again.${NC}"
    fi
    ;;
  2)
    echo "Goodbye!"
    exit 0
    ;;
  *)
    echo -e "${RED}Error: Invalid choice. Please enter 1 or 2.${NC}"
    ;;
  esac
done
