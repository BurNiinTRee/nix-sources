{
  description = "My Nixos System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, ... }:
    {
      nixosConfigurations = {
        "muehml" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit nixpkgs; };
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
}
