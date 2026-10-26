#!/bin/bash
REPO="RH124_Lab6_Virtualization-and-Containers"

sudo dnf install -y git || exit 1
cd ~ || exit 1

if [ -d "$REPO/.git" ]; then
    git -C "$REPO" pull --ff-only
else
    git clone "https://github.com/Red-Hat-Academy-Texas-A-M-University/${REPO}.git" || exit 1
fi

cd "$REPO" || exit 1
bash setup.sh
