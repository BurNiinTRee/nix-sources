{
  description = "My Nixos System";

  inputs = {
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-20.09-small";
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rnix-flake = {
      url = "gitlab:jD91mZM2/nix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-release, home-manager, rnix-flake, deploy-rs, ... }:
    let
      overlays = (import ./overlays.nix);
    in
    {
      legacyPackages.x86_64-linux = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
        config = { allowUnfree = true; };
      };
      inherit (nixpkgs) lib;

      nixosConfigurations."muehml.eu" = nixpkgs-release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./server
        ];
      };

      deploy.nodes."muehml.eu" = {
        hostname = "muehml.eu";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."muehml.eu";
        };
        sshUser = "root";
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      nixosConfigurations.larstop2 = self.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix.package = pkgs.nixUnstable;
            nix.extraOptions = ''
              experimental-features = nix-command flakes
            '';
            nix.registry.pkgs = {
              to = {
                type = "path";
                path = "/home/lars/nix-sources";
              };
            };
            nixpkgs.overlays = overlays;
            nixpkgs.config = {
              allowUnfree = true;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lars = import ./home.nix inputs;
          })
          ./configuration.nix
          ./modules/gamemode.nix
          home-manager.nixosModules.home-manager
        ];
      };
      templates = {
        cargo-pijul = {
          path = ./templates/cargo-pijul;
          description = "A template for a simple cargo package built with cargo-import and version controlled with pijul";
        };
      };
    };
}
