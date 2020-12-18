{
  description = "My Nixos System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-20.09";
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rnix-flake = {
      url = "gitlab:jD91mZM2/nix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-release, home-manager, rnix-flake }:
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
                path = "/home/lars/Sync/nix-sources";
              };
            };
            nixpkgs.overlays = overlays;
            nixpkgs.config = {
              permittedInsecurePackages = [ "python2.7-cryptography-2.9.2" ];
              allowUnfree = true;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lars = import ./home.nix rnix-flake;
          })
          ./configuration.nix
          ./modules/gamemode.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
