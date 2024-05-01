{
  inputs,
  selfLocation,
  ...
}: let
  inherit
    (inputs)
    agenix
    devenv
    treefmt-nix
    ;
in {
  systems = ["x86_64-linux"];
  _module.args.selfLocation = "/home/user/bntr";

  imports = [
    ./flake/nixpkgs.nix
    ./nixos
    ./templates
    devenv.flakeModule
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

    devenv.shells.default = {
      lib,
      pkgs,
      ...
    }: {
      containers = lib.mkForce {};
      packages = [pkgs.agenix pkgs.nixos-rebuild];
      env.RULES = "${selfLocation}/secrets/secrets.nix";
    };

    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
    };
  };
}
