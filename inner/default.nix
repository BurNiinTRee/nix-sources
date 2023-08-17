{inputs, ...}: let
  selfLocation = "/home/user/bntr";
  inherit
    (inputs)
    agenix
    disko
    home-manager
    impermanence
    nix-ld
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
  flake.templates.rust = {
    path = ./templates/rust;
    description = "Rust Template using fenix, devenv, and flake-parts";
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
          ./nixos/larstop2
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
                nix-index-db.hmModules.nix-index
              ];
              _module.args.flakeInputs = inputs;
              _module.args.selfLocation = selfLocation;
            };
          })
        ];
      };
      muehml = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/muehml
          simple-nixos-mailserver.nixosModules.mailserver
          agenix.nixosModules.default
          {
            _module.args.flakeInputs = inputs;
          }
        ];
      };

      htpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
