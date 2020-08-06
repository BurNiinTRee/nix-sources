{
  description = "My Nixos System";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {

    legacyPackages.x86_64-linux = import nixpkgs { system = "x86_64-linux"; overlays = import ./overlays.nix; };
    inherit (nixpkgs) lib;

    nixosConfigurations.larstop2 = self.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          nix.registry.nixpkgs.flake = self;
        })
      ];
    };
  };
}
