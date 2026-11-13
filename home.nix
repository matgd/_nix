{ config, pkgs, username, homeDirectory, profile ? "all", ... }:

let
  # Packages common for both profiles (work and personal)
  commonPackages = with pkgs; [
    # --- Shell & Terminal ---
    fish
    starship
    zellij

    # --- Version managers ---
    fnm
    uv

    # --- Utilities & Modern CLI replacements ---
    bat
    delta
    eza
    fd
    fzf
    git
    htop
    lazygit
    opencode
    ripgrep
    tldr
    zoxide

    # --- Editors ---
    vim
    neovim
    helix
    vscodium
    obsidian

    # --- Terminal ---
    kitty

    # --- Launcher ---
    rofi

    # --- Music ---
    spotify
  ];

  # Packages exclusively for the personal profile (@all) – e.g. gaming, GUI apps
  personalPackages = with pkgs; [
    mangohud
  ];

  # Select packages based on the active profile
  selectedPackages =
    if profile == "work" then
      commonPackages
    else
      commonPackages ++ personalPackages;
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  # Do not change this value unless you understand the Home Manager release notes.
  home.stateVersion = "24.05";

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # MUST HAVE FOR NON-NIXOS LINUX DISTROS:
  targets.genericLinux.enable = true;

  # Automatically sync desktop applications to ~/.local/share/applications
  xdg.enable = true;

  # Packages installed globally for the user profile
  home.packages = selectedPackages;

  # Enable and configure Zoxide (Smart cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable and configure Fish
  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat --style=plain";
      v = "nvim";
      nvm = "echo 'use fnm instead'";
    };

    shellAbbrs = {
      gc = "git commit";
      gf = "git fetch";
      gs = "git status";
      lg = "lazygit";
    };

    interactiveShellInit = ''
      set fish_greeting  # Disable default greeting banner
      fnm env --use-on-cd --shell fish | source  # Set up 'fnm'
    '';
  };

  # Clean, dedicated commands instead of parsing flags in hms:
  programs.fish.functions.hms-all = {
    body = ''
      set -l flake /home/mateusz/Personal_Projects/_nix
      if test (uname) = Darwin
          set flake /Users/mateusz/Personal_Projects/_nix
      end

      set -l os_base linux
      switch (uname -m)
          case arm64 aarch64
              set os_base mac-arm
          case x86_64
              if test (uname) = Darwin
                  set os_base mac-intel
              end
      end

      echo "--> Switching to PERSONAL profile (all)..."
      home-manager switch --flake "$flake#$os_base@all" $argv
    '';
  };

  programs.fish.functions.hms-work = {
    body = ''
      set -l flake /home/mateusz/Personal_Projects/_nix
      if test (uname) = Darwin
          set flake /Users/mateusz/Personal_Projects/_nix
      end

      set -l os_base linux
      switch (uname -m)
          case arm64 aarch64
              set os_base mac-arm
          case x86_64
              if test (uname) = Darwin
                  set os_base mac-intel
              end
      end

      echo "--> Switching to WORK profile..."
      home-manager switch --flake "$flake#$os_base@work" $argv
    '';
  };

  # Enable and configure Starship
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$status$character";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        truncation_length = 3;
        style = "bold cyan";
      };

      status = {
        disabled = false;
        format = "[$status]($style) ";
        style = "bold red";
        success_style = "bold green";
        map_symbol = true;
        recognize_signal_code = true;
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold yellow";
        format = "([\\[ $all_status$ahead_behind\\]]($style) )";
        ahead = "ahead:$count ";
        behind = "behind:$count ";
        diverged = "diverged:ahead:$ahead_count behind:$behind_count ";
        staged = "+$count ";
        modified = "!$count ";
        untracked = "?$count ";
        renamed = "»$count ";
        deleted = "✘$count ";
        conflicted = "=$count ";
      };
    };
  };

  # Enable Home Manager management
  programs.home-manager.enable = true;

  # Desktop entries sync (only if the profile includes personal/GUI packages)
  home.file = if profile == "all" then builtins.listToAttrs (
    builtins.concatLists (
      map (pkg:
        let
          appsDir = "${pkg}/share/applications";
        in
        if builtins.pathExists appsDir then
          map (file: {
            name = ".local/share/applications/${file}";
            value = { source = "${appsDir}/${file}"; };
          }) (builtins.attrNames (builtins.readDir appsDir))
        else
          [ ]
      ) personalPackages
    )) else { };
}
