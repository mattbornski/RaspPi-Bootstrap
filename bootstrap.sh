#!/bin/bash

echo "Setting up WiFi..."
iwlist wlan0 scan | grep -oE 'ESSID:"(.+)"' | cut -d\" -f2
read -p "Which SSID? " SSID
if [ "$SSID" != "" ] ; then
  read -p "Network password for ${SSID}? " PASSWORD
  wpa_passphrase ${SSID} ${PASSWORD} | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
  
  cat <<EOF | sudo tee /etc/network/interfaces
auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0
auto wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf

iface default inet dhcp
EOF
  
  sudo ifdown wlan0
  sudo ifup wlan0
  
  iwconfig wlan0
else
  echo "No SSID given, no WiFi will be set up"
fi

sudo apt-get update
sudo apt-get install avahi-daemon
sudo apt-get install git-core python2.7 python-setuptools
