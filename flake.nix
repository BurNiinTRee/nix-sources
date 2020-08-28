{
  description = "My Nixos System";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager = {
    url = "github:rycee/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {

    legacyPackages.x86_64-linux = import nixpkgs {
      system = "x86_64-linux";
      overlays = import ./overlays.nix;
      config = { allowUnfree = true; };
    };
    inherit (nixpkgs) lib;

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
          nixpkgs.overlays = import ./overlays.nix;
          nixpkgs.config.allowUnfree = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.lars = import ./home.nix;
        })
        ./configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
