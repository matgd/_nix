# Personal Nix Home Manager Setup

A reproducible, cross-platform user environment configuration managed via **Nix Flakes** and **Home Manager**. 

Works across Linux distributions (Linux Mint, Ubuntu, Arch, Fedora) and macOS (Intel & Apple Silicon) without polluting system-wide packages.

---

## Prerequisites

1. **Install Nix:**
- https://nixos.org/download/
- `sudo apt install nix-bin`

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

## Not included

- **[Zed](https://zed.dev/)**
  - relies on GPU rendering, tricky with nix and when working on various types of GPUs
- **[PyCharm](https://www.jetbrains.com/pycharm/)**
  - long time since I used it, not necessary for now
- **X11/Wayland specific tools/configs**
  - many distros use Wayland by default now, some (e.g. Linux Mint) dospo not
 

---

## Daily Usage

### Applying Updates / Config Changes

When updating package lists in `home.nix` or modifying parameters:

```bash
# On Linux
home-manager switch --flake .#mateusz-linux

# On macOS (Apple Silicon)
home-manager switch --flake .#mateusz-mac-arm

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
