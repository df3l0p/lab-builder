#! /bin/bash

export DEBIAN_FRONTEND=noninteractive
#sed -i 's/archive.ubuntu.com/us.archive.ubuntu.com/g' /etc/apt/sources.list
SPK_VERSION="$1"
SPK_HASH="$2"

apt_install_prerequisites() {
  # set timezone to UTC
  timedatectl set-timezone UTC
  # Install prerequisites and useful tools
  apt-get update
  apt-get install -y jq whois build-essential git docker docker-compose unzip mc
}

fix_eth1_static_ip() {
  # There's a fun issue where dhclient keeps messing with eth1 despite the fact
  # that eth1 has a static IP set. We workaround this by setting a static DHCP lease.
  echo -e 'interface "eth1" {
    send host-name = gethostname();
    send dhcp-requested-address 192.168.38.105;
  }' >> /etc/dhcp/dhclient.conf
  service networking restart
  # Fix eth1 if the IP isn't set correctly
  ETH1_IP=$(ifconfig eth1 | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
  if [ "$ETH1_IP" != "192.168.38.105" ]; then
    echo "Incorrect IP Address settings detected. Attempting to fix."
    ifdown eth1
    ip addr flush dev eth1
    ifup eth1
    ETH1_IP=$(ifconfig eth1 | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
    if [ "$ETH1_IP" == "192.168.38.105" ]; then
      echo "The static IP has been fixed and set to 192.168.38.105"
    else
      echo "Failed to fix the broken static IP for eth1. Exiting because this will cause problems with other VMs."
      exit 1
    fi
  fi
}


install_splunk() {
  # Check if Splunk is already installed
  if [ -f "/opt/splunk/bin/splunk" ]; then
    # Configuring
    cp -r /vagrant/res/conf/splunk/sh/* /opt/splunk/etc/apps/
    echo "Splunk is already installed. Reconfiguring and restart"
    /opt/splunk/bin/splunk restart
  else
    echo "Installing Splunk..."
    # Get Splunk.com into the DNS cache. Sometimes resolution randomly fails during wget below
    dig @8.8.8.8 splunk.com
    # Download Splunk
    spk_file=splunk-${SPK_VERSION}-${SPK_HASH}-Linux-x86_64.deb
    wget --progress=bar:force -O $spk_file "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=${SPK_VERSION}&product=splunk&filename=splunk-${SPK_VERSION}-${SPK_HASH}-linux-2.6-amd64.deb&wget=true"
    dpkg -i $spk_file
    /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd changeme

    # Skip Splunk Tour and Change Password Dialog
    touch /opt/splunk/etc/.ui_login
    # Enable SSL Login for Splunk

    # Configuring
    cp -r /vagrant/res/conf/splunk/sh/* /opt/splunk/etc/apps/
    
    # Reboot Splunk to make changes take effect
    /opt/splunk/bin/splunk restart
    /opt/splunk/bin/splunk enable boot-start
  fi
}


main() {
  apt_install_prerequisites
  #fix_eth1_static_ip
  #install_python
  install_splunk
}

main
exit 0
