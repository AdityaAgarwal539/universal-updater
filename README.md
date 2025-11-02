# universal-updater

This script provides a convenient way to update packages across various package managers on Linux distributions and also handles updates on macOS. It aims to be a universal updater, detecting available package managers and running their respective update commands.

## Features

*   **Multi-Distribution Support:** Automatically detects and updates packages for:
    *   APT (Debian, Ubuntu, Mint)
    *   SNAP (various Linux distros)
    *   FLATPAK (various Linux distros)
    *   PACMAN (Arch Linux)
    *   YAY (Arch Linux AUR helper)
    *   PARU (Arch Linux AUR helper)
    *   DNF (Fedora, RHEL, CentOS Stream)
    *   YUM (older RHEL/CentOS)
    *   ZYPPER (openSUSE)
    *   EMERGE (Gentoo)
    *   APK (Alpine Linux)
*   **Firmware Updates:** Checks for and applies firmware updates using `fwupdmgr`.
*   **macOS Support:**
    *   Updates Homebrew packages.
    *   Checks for App Store and system updates using `softwareupdate`.
*   **Modular Design:** Each package manager has its own update function, making it easy to extend or modify.

## Usage

There are a few ways to run this script:

### 1. Local Execution

First, make the script executable:
```bash
chmod +x updater.sh
```
Then, run it. The script requires `sudo` privileges for most package manager operations:
```bash
./updater.sh
```

The script will automatically detect your operating system (Linux or macOS) and the available package managers, then proceed with the updates.

## Contributing

Contributions are welcome! If you have suggestions for new package managers, improvements, or bug fixes, please feel free to open an issue or submit a pull request.

## License

This project is open-sourced under the MIT License. See the `LICENSE` file for more details.
