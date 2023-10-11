{
  inputs = {
    bntr.url = "github:BurNiinTRee/nix-sources?dir=modules";
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
        devenv.shells.default = {
          lib,
          pkgs,
          ...
        }: {
          # https://github.com/cachix/devenv/issues/528
          containers = lib.mkForce {};
          packages = [
          ];
        };
      };
    });
}
