#!/bin/bash
# =========================================================
# Lab 6 - Virtualization & Containers : environment setup
#
# Usage:
#   ./setup.sh                 Student machine  (default; run by autosetup.sh)
#   ./setup.sh --docker-host   Shared remote Docker host (10.2.0.103) - instructors only
# =========================================================
set -u

ORANGE="\033[38;5;208m"
RED="\033[0;31m"
RESET="\033[0m"

setup() { echo -e "${ORANGE}[SETUP]${RESET} $1"; }
die()   { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

IMAGE="quay.io/krieg/rh124_lab6"
DOCKER_REPO="https://download.docker.com/linux/rhel/docker-ce.repo"

add_docker_repo() {
    sudo dnf install -y dnf-plugins-core || die "Could not install dnf-plugins-core"
    sudo dnf config-manager --add-repo "$DOCKER_REPO" || die "Could not add the Docker CE repo"
}

# ---------------------------------------------------------
# Remote Docker host (10.2.0.103)
# ---------------------------------------------------------
setup_docker_host() {
    # podman-docker / runc conflict with docker-ce on RHEL
    sudo dnf remove -y podman-docker podman runc &>/dev/null || true

    add_docker_repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io \
        || die "Could not install Docker CE"
    setup "Installed Docker CE and dependencies"

    # Accept remote TCP connections on 2375.
    # NOTE: unauthenticated and unencrypted - lab network only, never production.
    sudo mkdir -p /etc/systemd/system/docker.service.d
    printf '[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock\n' \
        | sudo tee /etc/systemd/system/docker.service.d/override.conf >/dev/null
    setup "Configured dockerd to listen on tcp://0.0.0.0:2375"

    sudo systemctl daemon-reload
    sudo systemctl enable docker
    sudo systemctl restart docker || die "Docker daemon failed to start (see: journalctl -u docker)"
    setup "Started and enabled Docker daemon with remote access"

    sudo systemctl enable --now firewalld
    sudo firewall-cmd --permanent --add-port=2375/tcp
    sudo firewall-cmd --reload
    setup "Opened firewall for Docker remote API (port 2375)"

    sudo docker pull "$IMAGE" || die "Could not pull $IMAGE"
    setup "Pre-pulled $IMAGE"

    setup "Remote Docker host setup complete."
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

case "${1:-}" in
    --docker-host) setup_docker_host ;;
    "")            setup_student ;;
    *)             die "Unknown option '$1'. Usage: $0 [--docker-host]" ;;
esac
