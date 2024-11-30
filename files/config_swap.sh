#!/bin/bash
# Bash script to increase the swap size if less than 4GB on a Raspberry Pi

# Immediately exit on errors
set -e

# If memory + swap less than 4 GB, increase swap size
memory="$(free | sed -n '2{p;q}' | sed 's/|/ /' | awk '{print $2}')"
swap="$(free | sed -n '3{p;q}' | sed 's/|/ /' | awk '{print $2}')"
if (( memory+swap <= 3906250 )); then
    new_swap=$((3906250-memory))
    new_swap=$((new_swap/1000))
    # Turn off current swap
    sudo dphys-swapfile swapoff
    # Increase swap to 2GB
    sudo sed -i "s/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=$new_swap/" /etc/dphys-swapfile
    # Apply new swap
    sudo dphys-swapfile setup
    # Re-enable swap
    sudo dphys-swapfile swapon

    echo "Increased the swap size, recommend rebooting."
    exit 0
fi

echo "Don't need to increase the swap size."