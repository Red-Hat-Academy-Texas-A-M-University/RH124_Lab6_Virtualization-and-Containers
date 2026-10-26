#!/bin/bash
# =========================================================
# Lab 6 - Virtualization & Containers : student environment setup
# Run on the student's lab system (autosetup.sh calls this).
# =========================================================
set -u

ORANGE="\033[38;5;208m"
RED="\033[0;31m"
RESET="\033[0m"

setup() { echo -e "${ORANGE}[SETUP]${RESET} $1"; }
die()   { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

DOCKER_REPO="https://download.docker.com/linux/rhel/docker-ce.repo"

add_docker_repo() {
    sudo dnf install -y dnf-plugins-core || die "Could not install dnf-plugins-core"
    sudo dnf config-manager --add-repo "$DOCKER_REPO" || die "Could not add the Docker CE repo"
}

# ---------------------------------------------------------
# Student machine
# ---------------------------------------------------------
setup_student() {
    sudo dnf install -y git policycoreutils-python-utils firewalld \
        || die "Could not install base tooling"
    # RHEL 9 ships curl-minimal, which conflicts with the full curl package
    command -v curl &>/dev/null || sudo dnf install -y curl-minimal \
        || die "Could not install curl"
    setup "Installed base tooling (git, curl, SELinux utils, firewalld)"

    # Students install httpd themselves in step 1a
    sudo systemctl disable --now httpd &>/dev/null || true
    sudo dnf remove -y httpd &>/dev/null || true
    setup "Ensured httpd is not pre-installed (students install it in step 1a)"

    # Clean web root so each attempt starts fresh
    sudo mkdir -p /var/www/html
    sudo rm -rf /var/www/html/* /var/www/html/.[!.]* 2>/dev/null || true
    setup "Reset /var/www/html to a clean state"

    sudo systemctl enable --now firewalld
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --reload
    setup "Opened firewall for HTTP (port 80)"

    # Section 2 needs the docker *client* only - the daemon lives on 10.2.0.103
    sudo dnf remove -y podman-docker &>/dev/null || true
    add_docker_repo
    sudo dnf install -y docker-ce-cli || die "Could not install the Docker CLI"
    setup "Installed Docker CLI (client only, for 'docker -H tcp://10.2.0.103:2375 ...')"

    setup "Lab 6 student environment setup complete."
}

setup_student
