#!/bin/bash
# Bash script to increase the swap size if less than 2GB on Raspberry Pis

# Immediately exit on errors
set -e

# Check current swap size
memory="$(sed -n -e 's/CONF_SWAPSIZE=//p' /etc/dphys-swapfile)"

# Increase swap size if less than 2GB
if (( memory < 2048 )); then
    # Turn off current swap
    sudo dphys-swapfile swapoff
    # Increase swap to 2GB
    sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
    # Apply new swap
    sudo dphys-swapfile setup
    # Re-enable swap
    sudo dphys-swapfile swapon

    echo "Increased the swap size, recommend rebooting."
    exit 0
fi

echo "Don't need to increase the swap size."