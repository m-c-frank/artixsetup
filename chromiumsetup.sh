#!/bin/bash

# Install Chromium
sudo pacman -S chromium

# Check if Chromium installed successfully
if [ $? -eq 0 ]; then
    # Launch Chromium with specified pages
    chromium "https://chrome.google.com/webstore/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb" \
            "https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb" \
            "https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm" \
            "https://chrome.google.com/webstore/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone" \
            "https://chrome.google.com/webstore/detail/video-speed-controller/nffaoalbilbmmfgbnbgppjihopabppdk/related"
else
    echo "Error: Chromium installation failed."
fi
