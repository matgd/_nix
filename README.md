# Personal Nix Home Manager Setup

A reproducible, cross-platform user environment configuration managed via **Nix Flakes** and **Home Manager**. 

Works across Linux distributions (Linux Mint, Ubuntu, Arch, Fedora) and macOS (Intel & Apple Silicon) without polluting system-wide packages.

---

## Prerequisites

1. **Install Nix:**

Run the install script (Linux only) - it installs Nix and packages not included in `home.nix` via your system package manager (apt, dnf, or pacman):
```bash
./install_missing_nix_packages_with_system_package_manager.sh
```
Or install Nix manually for your distribution:
- **Debian/Ubuntu/Mint:** `sudo apt install nix-bin`
- **Fedora:** `sudo dnf install nix`
- **Arch:** `sudo pacman -S nix`
- **macOS:** https://nixos.org/download/

2. **Enable Flakes** (if not enabled globally):
```shell
mkdir -p ~/.config/nix/ && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

## Apply the configuration for your target system:
* **Linux (Linux Mint, Ubuntu, Arch, Fedora, etc.):**
```bash
nix run github:nix-community/home-manager -- switch --flake .#mateusz-linux

```


* **macOS (Apple Silicon - M1/M2/M3/M4):**
```bash
nix run github:nix-community/home-manager -- switch --flake .#mateusz-mac-arm

```


* **macOS (Intel):**
```bash
nix run github:nix-community/home-manager -- switch --flake .#mateusz-mac-intel

```

## Included in system package manager script (Linux only for now)
Some programs are not included in nix configuration due to pain points.

```bash
./install_missing_nix_packages_with_system_package_manager.sh
```

## Not included

- **[Zed](https://zed.dev/)**
  - relies on GPU rendering, needs non-NixOS setup, has frequent updates - I prefer to install standalone
- **[PyCharm](https://www.jetbrains.com/pycharm/)**
  - long time since I used it, not necessary for now
- **X11/Wayland specific tools/configs**
  - many distros use Wayland by default now, some (e.g. Linux Mint) do not - I don't want to keep both types of configs
 

---

## Daily Usage

### Applying Updates / Config Changes

When updating package lists in `home.nix` or modifying parameters:

```bash
# On Linux
home-manager switch --flake .#mateusz-linux

# On macOS (Apple Silicon)
home-manager switch --flake .#mateusz-mac-arm

# On macOS (Intel)
home-manager switch --flake .#mateusz-mac-intel

```

### Updating Package Versions

To update all packages to the latest available versions on `nixos-unstable`:

```bash
nix flake update
home-manager switch --flake .#mateusz-linux

```

---

## Post-Install Tips

### Set Fish as Default Shell

To change your default shell to Fish installed via Nix:

```bash
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"

```
