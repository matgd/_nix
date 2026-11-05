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
      mkHomeConfig = { system, username, homeDirectory, withGui ? true }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username homeDirectory withGui; };
          modules = [ ./home.nix ];
        };

      # Generates both a full and a GUI-less configuration for a platform
      mkPlatform = { name, system, homeDirectory }: {
        "${name}" = mkHomeConfig {
          inherit system homeDirectory;
          username = "mateusz";
        };
        "${name}-nogui" = mkHomeConfig {
          inherit system homeDirectory;
          username = "mateusz";
          withGui = false;
        };
      };
    in
    {
      homeConfigurations =
        (mkPlatform {
          name = "mateusz-linux";
          system = "x86_64-linux";
          homeDirectory = "/home/mateusz";
        }) // (mkPlatform {
          name = "mateusz-mac-arm";
          system = "aarch64-darwin";
          homeDirectory = "/Users/mateusz";
        }) // (mkPlatform {
          name = "mateusz-mac-intel";
          system = "x86_64-darwin";
          homeDirectory = "/Users/mateusz";
        });
    };
}
