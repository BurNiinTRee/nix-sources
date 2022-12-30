{
  description = "My Nixos System";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-db = {
      url = "https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux";
      flake = false;
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # impermanence test
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    home-manager,
    nixpkgs-stable,
    flake-parts,
    treefmt-nix,
    # impermanence test
    nixos-generators,
    impermanence,
    disko,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      flake-parts-lib,
      withSystem,
      ...
    }: let
      selfLocation = "/var/home/user/nix-sources";
    in {
      systems = ["x86_64-linux"];

      imports = [
        ./flake-modules/nixpkgs.nix
        treefmt-nix.flakeModule
      ];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        legacyPackages = pkgs;
        nixpkgs.overlays = [agenix.overlay];

        packages = {
          impermanence-test = nixos-generators.nixosGenerate {
            inherit system;
            format = "install-iso";
            modules = [
              ./impermanence-test/iso.nix
              disko.nixosModules.disko
              ({
                config,
                lib,
                ...
              }: {
                isoImage.compressImage = lib.mkForce false;
              })
            ];
            specialArgs = {inherit self;};
          };

          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [pkgs.nix config.packages.deploy];
            text = ''
              nix flake update --commit-lock-file ${selfLocation}
              deploy
            '';
          };
          deploy = pkgs.writeShellApplication {
            name = "deploy";
            runtimeInputs = [config.packages.home config.packages.muehml];
            text = ''
              home # home-manager switch
              muehml # deploy to muehml.eu
            '';
          };
          home = pkgs.writeShellApplication {
            name = "home";
            runtimeInputs = [pkgs.home-manager];
            text = ''
              home-manager switch
            '';
          };
          muehml = pkgs.writeShellApplication {
            name = "muehml";
            runtimeInputs = [pkgs.nixos-rebuild];
            text = ''
              nixos-rebuild switch --target-host muehml --flake bntr#muehml
            '';
          };
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [pkgs.agenix pkgs.nixos-rebuild];
          RULES = "${self}/secrets/secrets.nix";
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
        };

        formatter = config.treefmt.build.wrapper;
      };
      flake = {
        homeConfigurations = {
          user = withSystem "x86_64-linux" ({pkgs, ...}:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [./home/user.nix];
              extraSpecialArgs = {
                flakeInputs = inputs;
                inherit selfLocation;
              };
            });
        };

        nixosConfigurations = {
          "muehml" = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {flakeInputs = inputs;};
            modules = [
              ./server
              agenix.nixosModule
            ];
          };

          impermanence-test = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./impermanence-test/configuration.nix
              impermanence.nixosModule
              disko.nixosModules.disko
            ];
          };
        };
        flakeModules = {
          nixpkgs = ./flake-modules/nixpkgs.nix;
          default = self.flakeModules.nixpkgs;
        };
      };
    });
}
