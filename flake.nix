{
  description = "My Nixos System";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:BurNiinTRee/flake-parts";
  };

  outputs = { self, nixpkgs, agenix, home-manager, nixpkgs-stable, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, pkgs, system, ... }: {
        legacyPackages = pkgs;
        nixpkgs.overlays = [ agenix.overlay ];

        packages = {
          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [ pkgs.nix config.packages.deploy ];
            text = ''
              nix flake update --commit-lock-file /var/home/user/nix-sources
              deploy
            '';
          };
          deploy = pkgs.writeShellApplication {
            name = "deploy";
            runtimeInputs = [ config.packages.home config.packages.muehml ];
            text = ''
              home # home-manager switch
              muehml # deploy to muehml.eu
            '';
          };
          home = pkgs.writeShellApplication {
            name = "home";
            runtimeInputs = [ pkgs.home-manager ];
            text = ''
              home-manager switch --flake pkgs
            '';
          };
          muehml = pkgs.writeShellApplication {
            name = "muehml";
            runtimeInputs = [ pkgs.nixos-rebuild ];
            text = ''
              nixos-rebuild switch --target-host muehml --flake pkgs#muehml
            '';
          };
        };




        devShells.default = pkgs.mkShell {
          packages = [ pkgs.agenix ];
          RULES = "${self}/secrets/secrets.nix";
        };
        formatter = pkgs.nixpkgs-fmt;
      };
      flake = {
        homeConfigurations = {
          user = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
            modules = [ ./home/user.nix ];
            extraSpecialArgs = { flakeInputs = inputs; };
          };
        };


        nixosConfigurations = {
          "muehml" = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { flakeInputs = inputs; };
            modules = [
              ./server
              agenix.nixosModule
            ];
          };

          rpi = nixpkgs-stable.lib.nixosSystem {
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
