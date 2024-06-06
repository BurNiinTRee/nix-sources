{
  self,
  inputs,
  selfLocation,
  ...
}: let
  inherit
    (inputs)
    agenix
    treefmt-nix
    ;
in {
  systems = ["x86_64-linux"];
  _module.args.selfLocation = "/home/user/bntr";

  imports = [
    ./flake/nixpkgs.nix
    ./nixos
    ./templates
    treefmt-nix.flakeModule
  ];

  flake.flakeModules = {
    nixpgks = ./flake/nixpkgs.nix;
  };

  perSystem = {
    config,
    pkgs,
    system,
    self',
    ...
  }: {
    nixpkgs.overlays = [agenix.overlays.default];

    devShells.default = pkgs.mkShell {
      packages = [pkgs.agenix pkgs.nixos-rebuild];
      env.RULES = "${selfLocation}/secrets/secrets.nix";
    };

    checks = {
      muehml = self.nixosConfigurations.muehml.config.system.build.toplevel;
      larstop2 = self.nixosConfigurations.larstop2.config.system.build.toplevel;
    };

    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
    };
  };
}
