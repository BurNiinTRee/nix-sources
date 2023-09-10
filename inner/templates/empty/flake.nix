{
  inputs = {
    bntr.url = "github:BurNiinTRee/nix-sources?dir=inner";
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    bntr,
    devenv,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      systems = ["x86_64-linux"];

      imports = [(bntr + /flake/nixpkgs.nix) devenv.flakeModule];

      perSystem = {
        devenv.shells.default = {pkgs, ...}: {
          packages = [
          ];
        };
      };
    });
}
