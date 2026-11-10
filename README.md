# Personal Nix Home Manager Setup

A reproducible, cross-platform user environment configuration managed via **Nix Flakes** and **Home Manager**. 

Works across Linux distributions (Linux Mint, Ubuntu, Arch, Fedora) and macOS (Intel & Apple Silicon) without polluting system-wide packages. Supports **Work** and **Personal** (`all`) profiles out of the box.

---

## Profile Overview

- **`@all` (Personal & Work):** Installs common CLI tools + GUI applications (Obsidian, Spotify, Kitty, Rofi, MangoHud).
- **`@work` (Work Only):** Lightweight setup containing strictly shell tools, utilities, and lightweight editors (`vscodium`, `neovim`, `helix`).

---

## Prerequisites

1. **Install Nix:**

Run the install script (Linux only) - it installs Nix and packages not included in `home.nix` via your system package manager (apt, dnf, or pacman):
```bash
./install_missing_nix_packages_with_system_package_manager.sh
```


Or install Nix manually for your distribution:

* **Debian/Ubuntu/Mint:** `sudo apt install nix-bin`
* **Fedora:** `sudo dnf install nix`
* **Arch:** `sudo pacman -S nix`
* **macOS:** https://nixos.org/download/

2. **Enable Flakes** (if not enabled globally):

```shell
mkdir -p ~/.config/nix/ && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

## Initial Installation

Apply the initial configuration for your platform and chosen profile (`all` or `work`):

### Linux (x86_64)

```bash
# Personal / Full Profile
nix run github:nix-community/home-manager -- switch --flake .#linux@all

# Work Profile
nix run github:nix-community/home-manager -- switch --flake .#linux@work
```

### macOS (Apple Silicon - M1/M2/M3/M4)

```bash
# Personal / Full Profile
nix run github:nix-community/home-manager -- switch --flake .#mac-arm@all

# Work Profile
nix run github:nix-community/home-manager -- switch --flake .#mac-arm@work
```

### macOS (Intel)

```bash
# Personal / Full Profile
nix run github:nix-community/home-manager -- switch --flake .#mac-intel@all

# Work Profile
nix run github:nix-community/home-manager -- switch --flake .#mac-intel@work
```

---

## Daily Usage

After applying the configuration, Fish functions `hms-all` and `hms-work` are available in your shell to simplify switching and updating profiles across operating systems automatically.

### Switching Profiles / Applying Config Changes

```bash
# Switch to Personal Profile (includes GUI apps)
hms-all

# Switch to Work Profile (CLI/Minimal)
hms-work

# Pass extra home-manager arguments (e.g. show backtrace on error)
hms-all --show-trace
```

### Manual Home Manager Switch (Alternative)

If you are using another shell (e.g. Bash/Zsh) or running manually:

```bash
# Example for Linux
home-manager switch --flake .#linux@all
home-manager switch --flake .#linux@work

# Example for macOS Apple Silicon
home-manager switch --flake .#mac-arm@all
```

### Updating Package Versions

To update all packages to the latest available versions on `nixos-unstable`:

```bash
nix flake update
hms-all # or hms-work
```

---

## System Package Manager Integration (Linux Only)

Some programs are not included in the Nix configuration due to platform pain points or rendering dependencies:

```bash
./install_missing_nix_packages_with_system_package_manager.sh
```

### Not Included in Nix Flake

* **[Zed](https://zed.dev/)**
* Relies on GPU rendering, needs non-NixOS setup, has frequent updates - preferred to install standalone.


* **[PyCharm](https://www.jetbrains.com/pycharm/)**
* Not necessary for current workflow.


* **X11/Wayland specific tools/configs**
* Kept modular to ensure desktop-environment independence across Linux distros and macOS.



---

## Post-Install Tips

### Set Fish as Default Shell

To change your default shell to Fish installed via Nix:

```bash
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```
