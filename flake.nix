{
  description = "My Nixos System";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs = {
    #   url = "path:///home/user/projects/nixpkgs";
    # };
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

    nix-ld = {
      url = "git+file:///home/user/projects/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    nix-ld,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      flake-parts-lib,
      withSystem,
      ...
    }: let
      selfLocation = "/home/user/bntr";
    in {
      systems = ["x86_64-linux"];

      imports = [
        ./modules/flake-parts/nixpkgs.nix
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
          scripts = pkgs.callPackages ./scripts {inherit scripts selfLocation;};
        in
          scripts
          // {
            larstop2Iso = nixos-generators.nixosGenerate {
              inherit system;
              format = "install-iso";
              modules = [
                ./nixos-configurations/larstop2/installer.nix
                disko.nixosModules.disko
                {
                  _module.args.self = self;
                }
              ];
            };
          };

        devShells.default = pkgs.mkShellNoCC {
          packages =
            [pkgs.agenix pkgs.nixos-rebuild]
            ++ (with self'.packages; [
              update
              deploy
              larstop2
              muehml
              htpc
              iso
            ]);
          RULES = "${selfLocation}/secrets/secrets.nix";
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
        };

        formatter = config.treefmt.build.wrapper;
      };
      flake = {
        nixosConfigurations = {
          larstop2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nixos-configurations/larstop2
              nix-ld.nixosModules.nix-ld
              home-manager.nixosModules.home-manager
              impermanence.nixosModules.impermanence
              disko.nixosModules.disko
              ({lib, ...}: {
                system.configurationRevision = lib.mkIf (self ? rev) self.rev;
                home-manager.users.user = {
                  imports = [
                    ./home/user
                    impermanence.nixosModules.home-manager.impermanence
                    # import here as to not affect home-manager on fedora
                    ./home/user/impermanence.nix
                  ];
                  _module.args.flakeInputs = inputs;
                  _module.args.selfLocation = selfLocation;
                };
              })
            ];
          };
          muehml = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {flakeInputs = inputs;};
            modules = [
              simple-nixos-mailserver.nixosModules.mailserver
              ./nixos-configurations/server
              agenix.nixosModules.default
              attic.nixosModules.atticd
            ];
          };

          htpc = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nixos-configurations/htpc
            ];
          };
        };
        flakeModules = {
          nixpkgs = ./modules/flake-parts/nixpkgs.nix;
          default = self.flakeModules.nixpkgs;
        };
      };
    });
}
