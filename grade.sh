#!/bin/bash
set -e

BASE=/opt/files
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

pass() { echo -e "${GREEN}[PASSED]${RESET} $1"; }
fail() { echo -e "${RED}[FAILED]${RESET} $1"; }

if [[ "$(sudo dnf info fortune-mod 2>/dev/null | grep Version | awk '{print $3}')" == "3.24.0" ]]; then
	pass "Fortune-mod is up to date"
else
	fail "Fortune-mod is not up to date"
fi

if [[ "$(sudo dnf info cowsay 2>/dev/null | grep Version | awk '{print $3}')" == "3.8.4" ]]; then
	pass "Cowsay is up to date"
else
	fail "Cowsay is not up to date"
fi
