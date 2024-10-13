#!/bin/sh

echo "Adding v2rayA signing key..."
if wget https://downloads.sourceforge.net/project/v2raya/openwrt/v2raya.pub -O /etc/opkg/keys/94cc2a834fb0aa03; then
    echo "v2rayA signing key added successfully."
else
    echo "Error: Unable to add v2rayA signing key."
    exit 1
fi

echo "Importing v2rayA feed..."
if ! grep -q "^src/gz v2raya" /etc/opkg/customfeeds.conf; then
    echo "Adding v2rayA feed to customfeeds.conf..."
    echo "src/gz v2raya https://downloads.sourceforge.net/project/v2raya/openwrt/$(. /etc/openwrt_release && echo "$DISTRIB_ARCH")" | tee -a "/etc/opkg/customfeeds.conf"
else
    echo "Feed for v2rayA already exists in customfeeds.conf, skipping."
fi

echo "Updating opkg feeds..."
if opkg update; then
    echo "opkg feeds updated successfully."
else
    echo "Error: Failed to update opkg feeds."
    exit 1
fi

echo "Installing v2rayA..."
if opkg install v2raya; then
    echo "v2rayA installed successfully."
else
    echo "Error: Failed to install v2rayA."
    exit 1
fi

echo "Installing firewall packages..."
install_firewall_packages() {
    if command -v fw4 > /dev/null 2>&1; then
        if opkg install kmod-nft-tproxy; then
            echo "Firewall packages for fw4 installed successfully."
        else
            echo "Error: Failed to install firewall packages for fw4."
            exit 1
        fi
    elif command -v fw3 > /dev/null 2>&1; then
        if opkg install iptables-mod-conntrack-extra && \
           opkg install iptables-mod-extra && \
           opkg install iptables-mod-filter && \
           opkg install iptables-mod-tproxy && \
           opkg install kmod-ipt-nat6; then
            echo "Firewall packages for fw3 installed successfully."
        else
            echo "Error: Failed to install firewall packages for fw3."
            exit 1
        fi
    fi
}
install_firewall_packages

echo "Installing Xray core..."
if opkg install xray-core; then
    echo "Xray core installed successfully."
else
    echo "Error: Failed to install Xray core."
    exit 1
fi

# Optional: Uncomment to install geoip and geosite databases
# echo "Installing geoip and geosite databases..."
# if opkg install v2fly-geoip && opkg install v2fly-geosite; then
#     echo "Geoip and geosite databases installed successfully."
# else
#     echo "Error: Failed to install geoip and geosite databases."
# fi

if opkg list-installed | grep -q 'luci'; then
    echo "Installing LuCI app for v2raya..."
    if opkg install luci-app-v2raya; then
        echo "LuCI app for v2raya installed successfully."
    else
        echo "Error: Failed to install LuCI app for v2raya."
        exit 1
    fi
fi

echo "Enabling and starting v2rayA service..."
if uci set v2raya.config.enabled='1' && uci commit v2raya && \
   /etc/init.d/v2raya enable && /etc/init.d/v2raya start; then
    echo "v2rayA service enabled and started successfully."
else
    echo "Error: Failed to enable and start v2rayA service."
    exit 1
fi

router_ip=$(uci get network.lan.ipaddr 2>/dev/null || echo 'your_router_ip')
echo "Installation complete. Access the v2rayA web UI at http://$router_ip:2017"
