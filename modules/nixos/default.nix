{
  inputs,
  selfLocation,
  ...
}: let
  inherit
    (inputs)
    self
    agenix
    attic
    disko
    home-manager
    impermanence
    nix-index-db
    nixpkgs
    nixpkgs-stable
    simple-nixos-mailserver
    nixos-wsl
    comin
    ;
in {
  flake.nixosConfigurations = let
    setup-inputs = {lib, ...}: {
      system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      _module.args.flakeInputs = inputs;
      _module.args.selfLocation = selfLocation;
    };
  in {
    larstop2 = nixpkgs.lib.nixosSystem {
      modules = [
        ./larstop2
        setup-inputs
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
        comin.nixosModules.comin
        {
          home-manager.users.user = {
            imports = [
              ../home/user
              impermanence.nixosModules.home-manager.impermanence
              nix-index-db.hmModules.nix-index
            ];
            _module.args.flakeInputs = inputs;
            _module.args.selfLocation = selfLocation;
          };
        }
      ];
    };
    work-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./work-laptop
        nixos-wsl.nixosModules.wsl
        setup-inputs
        home-manager.nixosModules.home-manager
        {
          home-manager.users.user = {
            imports = [
              ../home/user
              nix-index-db.hmModules.nix-index
              # I should get rid of this
              impermanence.nixosModules.home-manager.impermanence
              {
                muehml.reaper.enable = false;
              }
            ];
            _module.args.flakeInputs = inputs;
            _module.args.selfLocation = selfLocation;
          };
        }
      ];
    };
    muehml = nixpkgs-stable.lib.nixosSystem {
      modules = [
        ./muehml
        setup-inputs
        agenix.nixosModules.default
        attic.nixosModules.atticd
        comin.nixosModules.comin
        impermanence.nixosModules.impermanence
        simple-nixos-mailserver.nixosModules.mailserver
      ];
    };

    rpi = nixpkgs.lib.nixosSystem {
      modules = [
        ./rpi
        setup-inputs
      ];
    };
  };
}
