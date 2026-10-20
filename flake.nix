{
  description = "Cross-platform Home Manager configuration for Linux and macOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Function to generate Home Manager configurations per system
      mkHomeConfig = { system, username, homeDirectory }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username homeDirectory; };
          modules = [ ./home.nix ];
        };
    in
    {
      homeConfigurations = {
        # Linux configuration (Linux Mint, Arch, Fedora, Debian, etc.)
        "mateusz-linux" = mkHomeConfig {
          system = "x86_64-linux";
          username = "mateusz";
          homeDirectory = "/home/mateusz";
        };

        # macOS Configuration (Apple Silicon - M1/M2/M3/M4)
        "mateusz-mac-arm" = mkHomeConfig {
          system = "aarch64-darwin";
          username = "mateusz";
          homeDirectory = "/Users/mateusz";
        };

        # macOS Configuration (Intel-based Macs)
        "mateusz-mac-intel" = mkHomeConfig {
          system = "x86_64-darwin";
          username = "mateusz";
          homeDirectory = "/Users/mateusz";
        };
      };
    };
}
