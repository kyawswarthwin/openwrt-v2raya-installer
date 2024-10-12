#!/bin/sh

# Helper function to install packages
install_pkg() {
  if ! opkg list-installed | grep -q "$1"; then
    opkg install "$1"
  fi
}

echo "Adding v2rayA signing key..."
install_pkg wget-ssl
wget https://downloads.sourceforge.net/project/v2raya/openwrt/v2raya.pub -O /etc/opkg/keys/94cc2a834fb0aa03

echo "Importing v2rayA feed..."
echo "src/gz v2raya https://downloads.sourceforge.net/project/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"

echo "Updating opkg feeds..."
opkg update

echo "Installing v2rayA..."
install_pkg v2raya

echo "Installing firewall packages..."
install_firewall_packages() {
  if command -v fw4 > /dev/null 2>&1; then
    install_pkg kmod-nft-tproxy
  elif command -v fw3 > /dev/null 2>&1; then
    install_pkg iptables-mod-conntrack-extra
    install_pkg iptables-mod-extra
    install_pkg iptables-mod-filter
    install_pkg iptables-mod-tproxy
    install_pkg kmod-ipt-nat6
  fi
}
install_firewall_packages

echo "Installing Xray core..."
install_pkg xray-core

# Optional: Uncomment to install geoip and geosite databases
# echo "Installing geoip and geosite databases..."
# install_pkg v2fly-geoip
# install_pkg v2fly-geosite

if opkg list-installed | grep -q 'luci'; then
  echo "Installing LuCI app for v2raya..."
  install_pkg luci-app-v2raya
fi

echo "Enabling and starting v2rayA service..."
uci set v2raya.config.enabled='1'
uci commit v2raya
/etc/init.d/v2raya enable
/etc/init.d/v2raya start

router_ip=$(uci get network.lan.ipaddr 2>/dev/null || echo 'your_router_ip')
echo "Installation complete. Access the v2rayA web UI at http://$router_ip:2017"
