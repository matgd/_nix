{ pkgs, username, homeDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = homeDirectory;

  # Do not change this value unless you understand the Home Manager release notes.
  home.stateVersion = "24.05";

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # Packages installed globally for the user profile
  home.packages = with pkgs; [
    # Core CLI & Editors
    neovim
    fzf
    fish
    helix
    vscodium
    lazygit
    opencode  # CLI tool

    # Utilities & Modern CLI replacements
    ripgrep
    fd
    bat
    eza
    zoxide
    git
    starship
  ];

  # Enable Home Manager management
  programs.home-manager.enable = true;
}
