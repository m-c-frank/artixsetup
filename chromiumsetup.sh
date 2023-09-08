#!/bin/bash

# Install Chromium
sudo pacman -S chromium

# Check if Chromium installed successfully
if [ $? -eq 0 ]; then
    # Launch Chromium with specified pages
    chromium "https://chrome.google.com/webstore/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb"
else
    echo "Error: Chromium installation failed."
fi
