{
  inputs,
  selfLocation,
  ...
}: let
  inherit
    (inputs)
    self
    agenix
    disko
    home-manager
    impermanence
    nix-index-db
    nixpkgs
    nixpkgs-stable
    simple-nixos-mailserver
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
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
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
    muehml = nixpkgs-stable.lib.nixosSystem {
      modules = [
        ./muehml
        setup-inputs
        simple-nixos-mailserver.nixosModules.mailserver
        agenix.nixosModules.default
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
