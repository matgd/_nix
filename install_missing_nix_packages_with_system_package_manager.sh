#!/usr/bin/env bash

set -euo pipefail

COMMON_PACKAGE_NAMES=(
    "kitty"
)

APT_PACKAGE_NAMES=(
    "nix-bin"
)
DNF_PACKAGE_NAMES=(
    "nix"
)
PACMAN_PACKAGE_NAMES=(
    "nix"
)

AVAILABLE_PACKAGE_MANAGERS=()
for PM in apt dnf pacman; do
    if command -v "$PM" >/dev/null 2>&1; then
        AVAILABLE_PACKAGE_MANAGERS+=("$PM")
    fi
done

if (( ${#AVAILABLE_PACKAGE_MANAGERS[@]} > 1 )); then
    echo "Multiple supported package managers detected: ${AVAILABLE_PACKAGE_MANAGERS[*]}" >&2
    exit 1
fi

if (( ${#AVAILABLE_PACKAGE_MANAGERS[@]} == 0 )); then
    echo "No supported package manager found (expected one of: apt, dnf, pacman). Install nix manually: https://nixos.org/download/" >&2
    exit 2
fi

DETECTED_PACKAGE_MANAGER="${AVAILABLE_PACKAGE_MANAGERS[0]}"

case "$DETECTED_PACKAGE_MANAGER" in
    apt)    PM_SPECIFIC_PACKAGE_NAMES=("${APT_PACKAGE_NAMES[@]}") ;;
    dnf)    PM_SPECIFIC_PACKAGE_NAMES=("${DNF_PACKAGE_NAMES[@]}") ;;
    pacman) PM_SPECIFIC_PACKAGE_NAMES=("${PACMAN_PACKAGE_NAMES[@]}") ;;
esac

PACKAGES_TO_INSTALL=("${COMMON_PACKAGE_NAMES[@]}" "${PM_SPECIFIC_PACKAGE_NAMES[@]}")

function install_with_apt() {
    sudo apt update
    sudo apt install "${PACKAGES_TO_INSTALL[@]}"
}

function install_with_dnf() {
    sudo dnf install "${PACKAGES_TO_INSTALL[@]}"
}

function install_with_pacman() {
    sudo pacman -Sy --needed "${PACKAGES_TO_INSTALL[@]}"
}

case "$DETECTED_PACKAGE_MANAGER" in
    apt)    install_with_apt ;;
    dnf)    install_with_dnf ;;
    pacman) install_with_pacman ;;
esac
