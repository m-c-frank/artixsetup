ln -s /etc/runit/sv/wpa_supplicant  /run/runit/service
dhclient

rm /var/wpa_supplicant/wlan0
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

pacman -S chromium