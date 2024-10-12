# OpenWrt v2rayA Installer

This repository provides a shell script, `v2raya.sh`, to easily install **v2rayA** on OpenWrt-based routers. The script automatically downloads the necessary signing keys, adds custom feeds, updates package lists, installs required kernel modules, and sets up the v2rayA service.

## Features

- Automatically detects your OpenWrt version and architecture.
- Adds the necessary custom feeds for v2rayA based on your system's architecture.
- Updates the package lists to ensure you have the latest available packages.
- Installs required kernel modules for firewall functionality, supporting both **fw3** and **fw4**.
- Installs the **v2rayA** application and its dependencies.
- Optionally installs geoip and geosite databases for enhanced functionality (commented out by default).
- Installs the LuCI app for easier management through the web UI if LuCI is already installed.

## Prerequisites

- OpenWrt installed on your router.
- Access to your router via SSH.
- Sufficient storage space for installing v2rayA and its dependencies.

## Installation

1. SSH into your OpenWrt router.

2. Download the script directly:

   ```sh
   wget https://raw.githubusercontent.com/kyawswarthwin/openwrt-v2raya-installer/main/v2raya.sh
   ```

3. Make the script executable:

   ```sh
   chmod +x v2raya.sh
   ```

4. Run the script:

   ```sh
   ./v2raya.sh
   ```

5. Follow the on-screen instructions to complete the installation.

## Usage

After installation, the script will enable and start the v2rayA service automatically. You can access the v2rayA web UI by navigating to:

```
http://<your_router_ip>:2017
```

Replace `<your_router_ip>` with the actual IP address of your router, which can be retrieved using the command:

```sh
uci get network.lan.ipaddr
```

## Optional Features

To install the geoip and geosite databases for enhanced functionality, you can uncomment the respective lines in the script before running it:

```sh
# echo "Installing geoip and geosite databases..."
# if opkg install v2fly-geoip && opkg install v2fly-geosite; then
#     echo "Geoip and geosite databases installed successfully."
# else
#     echo "Error: Failed to install geoip and geosite databases."
# fi
```

These databases provide geo-location capabilities for your connections, improving the overall functionality of v2rayA.

### Note:

- Ensure that your router has sufficient storage space before enabling this feature.
- Uncommenting these lines will allow the script to automatically install the necessary databases during the installation process.

## Troubleshooting

If the script encounters any issues, you will see an error message. Common errors include:

- Failure to download the public key.
- Problems with updating the package lists.
- Installation errors due to insufficient system resources.

Ensure your router is connected to the internet during the installation process.

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any improvements or bug fixes.

---

### Explore More!

If you're interested in expanding your options, we also have the **OpenWrt Passwall Installer**. Learn more about it at the [OpenWrt Passwall Installer GitHub Repository](https://github.com/kyawswarthwin/openwrt-passwall-installer).
