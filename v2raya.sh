#!/bin/sh

echo "Adding v2rayA signing key..."
wget https://downloads.sourceforge.net/project/v2raya/openwrt/v2raya.pub -O /etc/opkg/keys/94cc2a834fb0aa03

echo "Importing v2rayA feed..."
echo "src/gz v2raya https://downloads.sourceforge.net/project/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"

echo "Updating opkg feeds..."
opkg update

echo "Installing v2rayA..."
opkg install v2raya

echo "Installing firewall packages..."
install_firewall_packages() {
  if command -v fw4 > /dev/null 2>&1; then
    opkg install kmod-nft-tproxy
  elif command -v fw3 > /dev/null 2>&1; then
    opkg install iptables-mod-conntrack-extra
    opkg install iptables-mod-extra
    opkg install iptables-mod-filter
    opkg install iptables-mod-tproxy
    opkg install kmod-ipt-nat6
  fi
}
install_firewall_packages

echo "Installing Xray core..."
opkg install xray-core

# Optional: Uncomment to install geoip and geosite databases
# echo "Installing geoip and geosite databases..."
# opkg install v2fly-geoip
# opkg install v2fly-geosite

if opkg list-installed | grep -q 'luci'; then
  echo "Installing LuCI app for v2raya..."
  opkg install luci-app-v2raya
fi

echo "Enabling and starting v2rayA service..."
uci set v2raya.config.enabled='1'
uci commit v2raya
/etc/init.d/v2raya enable
/etc/init.d/v2raya start

router_ip=$(uci get network.lan.ipaddr 2>/dev/null || echo 'your_router_ip')
echo "Installation complete. Access the v2rayA web UI at http://$router_ip:2017"
