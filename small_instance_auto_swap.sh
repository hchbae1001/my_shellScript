#!/bin/bash

# Minimum available memory (in MB)
MIN_MEM=512  # Create swap if available memory falls below 512MB

# Swap file size (in MB)
SWAP_SIZE=2048  # Create a 2GB swap file

# Location of the swap file
SWAP_FILE="/swapfile"

# Calculate the current available memory
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')

# Function to check available memory
function check_memory() {
    if [ "$AVAILABLE_MEM" -lt "$MIN_MEM" ]; then
        echo "Available memory ($AVAILABLE_MEM MB) is below the threshold ($MIN_MEM MB)."
        create_swap  # Create swap if memory is below the threshold
    else
        echo "Sufficient memory available: $AVAILABLE_MEM MB"
    fi
}

# Function to create swap
function create_swap() {
    echo "Creating swap file of size ${SWAP_SIZE}MB at $SWAP_FILE"
    
    # Create the swap file
    sudo fallocate -l "${SWAP_SIZE}M" "$SWAP_FILE"
    sudo chmod 600 "$SWAP_FILE"  # Set the correct permissions for the swap file
    sudo mkswap "$SWAP_FILE"  # Set up the swap area
    sudo swapon "$SWAP_FILE"  # Enable the swap

    echo "Swap file created and activated."
    
    # Add the swap file to /etc/fstab to make it permanent
    if ! grep -q "$SWAP_FILE" /etc/fstab; then
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
        echo "Swap file added to /etc/fstab."
    fi
}

# Check memory and create swap if needed
check_memory
