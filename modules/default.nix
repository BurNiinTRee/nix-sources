{inputs, ...}: let
  selfLocation = "/home/user/bntr";
  inherit
    (inputs)
    agenix
    disko
    home-manager
    impermanence
    nix-index-db
    nixos-generators
    nixpkgs
    nixpkgs-stable
    self
    simple-nixos-mailserver
    treefmt-nix
    ;
in {
  systems = ["x86_64-linux"];

  imports = [
    ./flake/nixpkgs.nix
    treefmt-nix.flakeModule
  ];
  flake.templates = {
    rust = {
      path = ./templates/rust;
      description = "Rust Template using fenix, devenv, and flake-parts";
    };
    empty = {
      path = ./templates/empty;
      description = "Empty Template using devenv and flake-parts";
    };
    callPackage = {
      path = ./templates/callPackage;
      description = "Simply create a package via callPackage";
    };
  };
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
            ./nixos/larstop2/installer.nix
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
          rpi
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
        modules = [
          ./nixos/larstop2
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          ({lib, ...}: {
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
            home-manager.users.user = {
              imports = [
                ./home/user
                impermanence.nixosModules.home-manager.impermanence
                nix-index-db.hmModules.nix-index
              ];
              _module.args.flakeInputs = inputs;
              _module.args.selfLocation = selfLocation;
            };
          })
        ];
      };
      muehml = nixpkgs-stable.lib.nixosSystem {
        modules = [
          ./nixos/muehml
          simple-nixos-mailserver.nixosModules.mailserver
          agenix.nixosModules.default
          {
            _module.args.flakeInputs = inputs;
          }
        ];
      };

      rpi = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/rpi
          (
            {lib, ...}: {
              _module.args.flakeInputs = inputs;
            }
          )
        ];
      };

      htpc = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/htpc
          {
            _module.args.flakeInputs = inputs;
          }
        ];
      };
    };
  };
}
