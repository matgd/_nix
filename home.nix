{ config, pkgs, username, homeDirectory, ... }:

let
  guiPackages = with pkgs; [
    # --- Workflow ---
    # kitty  # won't work OOTB -> GPU drivers

    # --- Editors ---
    vscodium
    # zed-editor  # won't work OOTB -> GPU drivers

    # --- Notes ---
    obsidian

    # --- Music ---
    spotify
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
  home.packages = (with pkgs; [
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
    # vscodium

    # --- LLM stuff ---
    opencode  # CLI tool

    # --- Utilities & Modern CLI replacements ---
    htop
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide
    rofi
    git
  ]) ++ guiPackages;

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

      # Home Manager quick-rebuild shortcut
      hms = "home-manager switch --flake /home/mateusz/Personal_Projects/_nix#mateusz-linux";
    };

    # Disable default greeting banner
    interactiveShellInit = ''
      set fish_greeting
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
  home.file = builtins.listToAttrs (
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
    )
  );
}
