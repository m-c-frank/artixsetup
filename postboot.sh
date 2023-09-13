#!/bin/bash

# Exit on error
set -e

WLAN_INTERFACE="wlan0"

# Copy wpa_supplicant configuration
echo "Copying wpa_supplicant.conf to the appropriate location..."

if [ -f ./wpa_supplicant.conf ]; then
    cp ./wpa_supplicant.conf /etc/wpa_supplicant/
else
    echo "wpa_supplicant.conf not found in the current directory. Exiting."
    exit 1
fi

echo "wpa_supplicant configuration done."

# wpa_supplicant service
echo "Setting up wpa_supplicant service..."

if [ ! -L /run/runit/service/wpa_supplicant ]; then
    ln -s /etc/runit/sv/wpa_supplicant /run/runit/service/
fi

echo "wpa_supplicant service setup done."

# Configure wpa_supplicant run script to include dhclient
echo "Configuring wpa_supplicant to run dhclient..."

sed -i "/^exec/i\dhclient $WLAN_INTERFACE &" /etc/runit/sv/wpa_supplicant/run

echo "dhclient setup done."

# Restart wpa_supplicant
echo "Restarting wpa_supplicant..."

sv restart wpa_supplicant

echo "wpa_supplicant restarted."

# Final output
echo "All done. Please check if you're connected and have an IP address using 'ip addr show $WLAN_INTERFACE'."

curl -LO raw.githubusercontent.com/m-c-frank/artixsetup/main/chromiumsetup.sh
curl -LO raw.githubusercontent.com/m-c-frank/artixsetup/main/miniconda.sh
