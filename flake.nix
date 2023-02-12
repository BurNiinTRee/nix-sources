{
  description = "My Nixos System";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    attic.url = "github:zhaofengli/attic";
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
    attic,
    agenix,
    home-manager,
    nixpkgs-stable,
    simple-nixos-mailserver,
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
        self',
        ...
      }: {
        legacyPackages = pkgs;
        nixpkgs.overlays = [agenix.overlays.default];

        packages = let
          ShellApplicationNoCheck = {
            name,
            text,
            runtimeInputs ? [],
          }:
            pkgs.writeShellApplication {
              inherit name text runtimeInputs;
              checkPhase = ''
                runHook preCheck
                ${pkgs.stdenv.shellDryRun} "$target"
                runHook postCheck
              '';
            };
        in {
          impermanence-test = nixos-generators.nixosGenerate {
            inherit system;
            format = "install-iso";
            modules = [
              ./impermanence-test/iso.nix
              disko.nixosModules.disko
            ];
            specialArgs = {inherit self;};
          };

          bcachefsIso = nixos-generators.nixosGenerate {
            inherit system;
            format = "install-iso";
            modules = [
              ({lib, ...}: {
                boot.supportedFilesystems = lib.mkForce ["vfat" "bcachefs"];
                # isoImage.squashfsCompression = "zstd -Xcompression-level 1";
              })
            ];
          };

          update = ShellApplicationNoCheck {
            name = "update";
            runtimeInputs = [pkgs.nix config.packages.deploy];
            text = ''
              nix flake update --commit-lock-file ${selfLocation}
              deploy
            '';
          };
          deploy = ShellApplicationNoCheck {
            name = "deploy";
            runtimeInputs = [config.packages.home config.packages.muehml];
            text = ''
              home # home-manager switch
              muehml # deploy to muehml.eu
            '';
          };
          home = ShellApplicationNoCheck {
            name = "home";
            runtimeInputs = [pkgs.home-manager];
            text = ''
              home-manager switch
            '';
          };
          muehml = ShellApplicationNoCheck {
            name = "muehml";
            runtimeInputs = [pkgs.nixos-rebuild];
            text = ''
              nixos-rebuild switch --target-host muehml --flake bntr#muehml
            '';
          };
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [pkgs.agenix pkgs.nixos-rebuild] ++ (with self'.packages; [update deploy muehml home]);
          RULES = "${selfLocation}/secrets/secrets.nix";
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
              simple-nixos-mailserver.nixosModules.mailserver
              ./server
              agenix.nixosModules.default
              attic.nixosModules.atticd
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
  nixConfig.extra-substituters = "https://staging.attic.rs/attic-ci";
  nixConfig.extra-trusted-public-keys = "attic-ci:U5Sey4mUxwBXM3iFapmP0/ogODXywKLRNgRPQpEXxbo=";
}
