{
  description = "My Nixos System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/lars/packages/nixpkgs";
    musnix = {
      url = "github:cidkidnix/musnix/flake-rework";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-21.11";
    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };
    rnix-flake = {
      url = "gitlab:jD91mZM2/nix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    modartt = {
      url = "path:/home/lars/Music/Modartt/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    reaper = {
      url = "path:/home/lars/Music/Reaper/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-release, ... }:
    let
      overlays = (import ./common/overlays.nix) ++ [
        inputs.musnix.overlay
        inputs.nix-matlab.overlay
      ];
    in
    {
      legacyPackages.x86_64-linux = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
        config = { allowUnfree = true; };
      };
      inherit (nixpkgs) lib;

      nixosConfigurations = {
        larstop2 = self.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs // { inherit overlays; };
          modules = [
            ./larstop2
          ];
        };

        "muehml" = nixpkgs-release.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { nixpkgs = nixpkgs-release; };
          modules = [
            ./server
          ];
        };

        rpi = nixpkgs-release.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { nixpkgs = nixpkgs-release; };
          modules = [
            ./rpi
          ];
        };
      };
    };
}
