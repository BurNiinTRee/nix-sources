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
  };

  outputs = { self, nixpkgs, agenix, home-manager, nixpkgs-unstable, ... }@inputs:
    {
      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-unstable { system = "x86_64-linux"; };
          extraSpecialArgs = { flakeInputs = inputs; };
          modules = [ ./fedora-home ];
        };
      };


      legacyPackages.x86_64-linux = import nixpkgs-unstable { system = "x86_64-linux"; };


      devShells.x86_64-linux.default = with nixpkgs-unstable.legacyPackages.x86_64-linux;
        mkShell {
          packages = [ nixos-rebuild ];
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
}
