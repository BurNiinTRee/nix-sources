{
  description = "My Nixos System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-parts.url = "github:BurNiinTRee/flake-parts";
  };

  outputs = { self, nixpkgs, agenix, home-manager, nixpkgs-unstable, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, pkgs, system, ... }: {
        legacyPackages = pkgs;
        nixpkgs.path = nixpkgs-unstable;
        nixpkgs.overlays = [ agenix.overlay ];

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixos-rebuild pkgs.agenix ];
          RULES = "${self}/secrets/secrets.nix";
        };

      };
      flake = {
        homeConfigurations = {
          user = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs-unstable {
              system = "x86_64-linux";
            };
            modules = [ ./fedora-home ];
          };
        };


        nixosConfigurations = {
          "muehml" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { flakeInputs = inputs; };
            modules = [
              ./server
              agenix.nixosModule
            ];
          };

          rpi = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { nixpkgs = nixpkgs; };
            modules = [
              ./rpi
            ];
          };
        };
      };
    };
}
