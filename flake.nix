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

    nix-index-db = {
      url = "https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux";
      flake = false;
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    home-manager,
    nixpkgs-stable,
    flake-parts,
    treefmt-nix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit self;} ({
      flake-parts-lib,
      withSystem,
      ...
    }: {
      systems = ["x86_64-linux"];

      imports = [
        ({flake-parts-lib, ...}: {
          options.perSystem = flake-parts-lib.mkPerSystemOption ({
            config,
            pkgs,
            lib,
            ...
          }: {
            options.treefmt =
              lib.mkOption
              {
                type = lib.types.submoduleWith {
                  modules = [treefmt-nix.lib.module-options] ++ treefmt-nix.lib.programs.modules;
                  specialArgs = {inherit pkgs;};
                };
                default = {};
              };
          });
        })
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
          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [pkgs.nix config.packages.deploy];
            text = ''
              nix flake update --commit-lock-file /var/home/user/nix-sources
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
              home-manager switch --flake pkgs
            '';
          };
          muehml = pkgs.writeShellApplication {
            name = "muehml";
            runtimeInputs = [pkgs.nixos-rebuild];
            text = ''
              nixos-rebuild switch --target-host muehml --flake pkgs#muehml
            '';
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [pkgs.agenix];
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
              extraSpecialArgs = {flakeInputs = inputs;};
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

          rpi = nixpkgs-stable.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = {nixpkgs = nixpkgs;};
            modules = [
              ./rpi
            ];
          };
        };
      };
    });
}
