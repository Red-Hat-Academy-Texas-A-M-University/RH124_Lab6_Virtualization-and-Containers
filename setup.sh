#!/bin/bash
set -e

BASE=/opt/files
ORANGE="\033[38;5;208m"
RESET="\033[0m"

setup() { echo -e "${ORANGE}[SETUP]${RESET} $1"; }

# --- Install outdated version of qcow ---
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm &&
sudo dnf install wget &&
wget https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/35/Everything/x86_64/os/Packages/c/cowsay-3.04-17.fc35.noarch.rpm &&
sudo dnf install ./cowsay-3.04-17.fc35.noarch.rpm -y &&
rm -f ./cowsay-3.04-17.fc35.noarch.rpm &&
setup "Downloaded Cowsay"
