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
    # Shell
    fish
    starship  # for fish

    # Version control related
    lazygit
    delta

    # Editors
    vim
    neovim
    helix
    vscodium

    # LLM stuff
    opencode  # CLI tool

    # Utilities & Modern CLI replacements
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide
    git
  ];

  # Enable and configure Fish
  programs.fish = {
    enable = true;
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
      format = "$directory$git_branch$git_status$character";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        truncation_length = 3;
        style = "bold cyan";
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
}
