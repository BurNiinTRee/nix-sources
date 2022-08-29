{
  description = "My Nixos System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        "muehml" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { nixpkgs = nixpkgs; };
          modules = [
            ./server
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
}
