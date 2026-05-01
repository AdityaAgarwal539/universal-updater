#!/bin/bash

# This script automatically detects and updates packages from various package managers.

# Function to print messages
print_message() {
  echo "----------------------------------------"
  echo "$1"
  echo "----------------------------------------"
}

# Create Timeshift snapshot if available
create_timeshift_snapshot(){
  command -v timeshift &>/dev/null || return 1
  print_message "Timeshift detected."
  read -rp "Create Timeshift snapshot before upgrading? [Y/n]: " ans
  ans=${ans:-Y}
  if [[ "$ans" =~ ^[Yy] ]]; then
    print_message "Creating Timeshift snapshot..."
    if [[ "$EUID" -eq 0 ]]; then
      timeshift --create --comments "Pre-upgrade snapshot" --tags D
    else
      sudo timeshift --create --comments "Pre-upgrade snapshot" --tags D
    fi
    return $?
  fi
  print_message "Skipping Timeshift snapshot as requested."
  return 0
}

# --- Update and Upgrade Functions ---

# APT (Debian/Ubuntu)
update_apt() {
  if command -v apt &>/dev/null; then
    print_message "Updating APT packages..."
    sudo apt update && sudo apt upgrade -y
  fi
}

# SNAP (Various Distros)
update_snap() {
  if command -v snap &>/dev/null; then
    print_message "Updating SNAP packages..."
    sudo snap refresh
  fi
}

# FLATPAK (Various Distros)
update_flatpak() {
  if command -v flatpak &>/dev/null; then
    print_message "Updating FLATPAK packages..."
    flatpak update -y
  fi
}

# PACMAN (Arch Linux)- if AUR helper is absent
update_pacman() {
  if command -v pacman &>/dev/null; then
    print_message "Updating PACMAN packages..."
    sudo pacman -Syu --noconfirm
  fi
}

# YAY (Arch Linux - AUR)
update_yay() {
  if command -v yay &>/dev/null; then
    if [[ -n "$SUDO_USER" && "$EUID" -eq 0 ]]; then
      print_message "Updating AUR packages with YAY (as $SUDO_USER)..."
      sudo -u "$SUDO_USER" yay -Syu --noconfirm
    elif [[ "$EUID" -ne 0 ]]; then
      print_message "Updating AUR packages with YAY..."
      yay -Syu --noconfirm
    else
      print_message "Skipping YAY (cannot determine user context)..."
    fi
  fi
}

# PARU (Arch Linux - AUR)
update_paru() {
  if command -v paru &>/dev/null; then
    if [[ -n "$SUDO_USER" && "$EUID" -eq 0 ]]; then
      print_message "Updating AUR packages with PARU (as $SUDO_USER)..."
      sudo -u "$SUDO_USER" paru -Syu --noconfirm
    elif [[ "$EUID" -ne 0 ]]; then
      print_message "Updating AUR packages with PARU..."
      paru -Syu --noconfirm
    else
      print_message "Skipping PARU (cannot determine user context)..."
    fi
  fi
}


# DNF (Fedora/RHEL)
update_dnf() {
  if command -v dnf &>/dev/null; then
    print_message "Updating DNF packages..."
    sudo dnf upgrade -y
  fi
}

# YUM (CentOS/RHEL/Fedora - older)
update_yum() {
  if command -v yum &>/dev/null; then
    print_message "Updating YUM packages..."
    sudo yum update -y
  fi
}

# ZYPPER (openSUSE)
update_zypper() {
  if command -v zypper &>/dev/null; then
    print_message "Updating ZYPPER packages..."
    sudo zypper refresh && sudo zypper update -y
  fi
}

# EMERGE (Gentoo)
update_emerge() {
  if command -v emerge &>/dev/null; then
    print_message "Updating EMERGE packages..."
    sudo emerge --sync
    sudo emerge -uDN --ask=n @world
  fi
}

# APK (Alpine Linux)
update_apk() {
  if command -v apk &>/dev/null; then
    print_message "Updating APK packages..."
    sudo apk update && sudo apk upgrade
  fi
}
# --- Firmware Update ---

# FWUPD (Linux Vendor Firmware Service)
update_firmware() {
  if command -v fwupdmgr &>/dev/null; then
    print_message "Checking for firmware updates..."
    sudo fwupdmgr refresh && sudo fwupdmgr update
  fi
}

# --- macOS Specific Updates ---
update_macos() {
  print_message "Starting macOS update..."

  # Homebrew
  if command -v brew &>/dev/null; then
    print_message "Updating Homebrew packages..."
    brew update && brew upgrade
  fi

  # App Store and System Updates
  print_message "Checking for App Store and System updates..."
  sudo softwareupdate -i -a --restart-required || true # --restart-required to avoid hanging
}
#}

# --- Main Execution ---

main() {
  print_message "Starting system update..."

  if [[ "$(uname)" == "Darwin" ]]; then
    update_macos
  else # Assume Linux
    # Create Timeshift snapshot (non-blocking if timeshift not installed)
    create_timeshift_snapshot || true

    # System and application updates
    # Prefers AUR helpers (paru then yay); falls back to pacman
    if command -v paru &>/dev/null; then
      update_paru
    elif command -v yay &>/dev/null; then
      update_yay
    else
      update_pacman
    fi
    update_apt
    update_snap
    update_flatpak
    update_dnf
    update_yum
    update_zypper
    update_emerge
    update_apk

    # Firmware updates
    update_firmware
  fi


  print_message "System update complete!"
}

main
