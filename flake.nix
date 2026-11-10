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
      # Function to generate Home Manager configurations per system and profile
      mkHomeConfig = { system, username, homeDirectory, profile }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username homeDirectory profile; };
          modules = [ ./home.nix ];
        };

      # Generates both @all and @work profiles for a given platform
      mkProfiles = { baseName, system, homeDirectory }:
      {
        "${baseName}@all"  = mkHomeConfig { inherit system homeDirectory; username = "mateusz"; profile = "all"; };
        "${baseName}@work" = mkHomeConfig { inherit system homeDirectory; username = "mateusz"; profile = "work"; };
      };
    in
    {
      homeConfigurations =
        (mkProfiles { baseName = "linux"; system = "x86_64-linux"; homeDirectory = "/home/mateusz"; }) //
        (mkProfiles { baseName = "mac-arm"; system = "aarch64-darwin"; homeDirectory = "/Users/mateusz"; }) //
        (mkProfiles { baseName = "mac-intel"; system = "x86_64-darwin"; homeDirectory = "/Users/mateusz"; });
    };
}