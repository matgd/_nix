{ config, pkgs, username, homeDirectory, withGui ? true, ... }:

let
  guiPackages = with pkgs; [
    # --- Workflow ---
    rofi
    kitty  # won't work OOTB -> GPU drivers

    # --- Editors ---
    vscodium
    # zed-editor  # won't work OOTB -> GPU drivers + I prefer to standalone install due to the frequent updates

    # --- Notes ---
    obsidian

    # --- Music ---
    spotify
  ];
  cliPackages = with pkgs; [
    # --- Shell ---
    fish
    starship  # for fish

    # -- Workflow --
    zellij

    # --- Version control related ---
    lazygit
    delta

    # --- Editors ---
    vim
    neovim
    helix

    # --- LLM stuff ---
    opencode  # CLI tool

    # --- Node version manager --- #
    fnm  # (f)ast (n)ode (m)anager

    # --- Utilities & Modern CLI replacements ---
    bat
    eza
    fd
    fzf
    git
    htop
    ripgrep
    tldr
    zoxide
  ];
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
  home.packages = cliPackages ++ (pkgs.lib.optionals withGui guiPackages);

  # Enable and configure Zoxide (Smart cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable and configure Fish
  programs.fish = {
    enable = true;

    # Fish Shell Aliases
    shellAliases = {
      # Modern CLI replacements
      cat = "bat --style=plain";

      # Git & Tools shortcuts
      gc = "git commit";
      gf = "git fetch";
      gs = "git status";
      lg = "lazygit";
      v = "nvim";
      nvm = "echo 'use fnm instead'";

      # Home Manager quick-rebuild shortcut
      # (actual hms logic is defined in the function below)
    };

    interactiveShellInit = ''
      set fish_greeting  # Disable default greeting banner, fnm startup
      fnm env --use-on-cd --shell fish | source  # Set up 'fnm'
    '';
  };

  # Home Manager rebuild: auto-detects OS/arch, supports `hms --no-gui`
  programs.fish.functions.hms = {
    body = ''
      set -l flake /home/mateusz/Personal_Projects/_nix
      if test (uname) = Darwin
          set flake /Users/mateusz/Personal_Projects/_nix
      end

      set -l host mateusz-linux
      switch (uname -m)
          case arm64 aarch64
              set host mateusz-mac-arm
          case x86_64
              if test (uname) = Darwin
                  set host mateusz-mac-intel
              end
      end

      if test "$argv[1]" = --no-gui
          set host "$host-nogui"
          set --erase argv[1]
      end

      home-manager switch --flake "$flake#$host" $argv
    '';
  };

  # Enable and configure Starship
  programs.starship = {
    enable = true;
    # Enables automatic integration for Fish shell
    enableFishIntegration = true;

    # Custom Starship Settings (Optional)
    settings = {
      add_newline = false;

      # Custom prompt format
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
        # Wraps all git flags inside brackets e.g. [ ahead:1 | +1 !2 ?1 ]
        format = "([\\[ $all_status$ahead_behind\\]]($style) )";

        # Explicit status indicators:
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

  # Entries in menu
  home.file = if withGui then builtins.listToAttrs (
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
      ) guiPackages
    )) else { };
}
