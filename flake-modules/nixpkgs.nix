#
# Nixpkgs module. The only exception to the rule.
#
# Provides a `pkgs` argument in `perSystem`.
#
# Arguably, this shouldn't be in flake-parts, but in nixpkgs.
# Nixpkgs could define its own module that does this, which would be
# a more consistent UX, but for now this will do.
#
# The existence of this module does not mean that other flakes' logic
# will be accepted into flake-parts, because it's against the
# spirit of Flakes.
#
{
  flake-parts-lib,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    mkOptionType
    ;
  inherit
    (flake-parts-lib)
    mkSubmoduleOptions
    ;
  overlayType = mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
in {
  # this module conflicts with the nixpkgs module in upstream flake-parts
  disabledModules = [(inputs.flake-parts + "/modules/nixpkgs.nix")];
  config = {
    perSystem = {
      config,
      inputs',
      ...
    }: let
      cfg = config.nixpkgs;
    in {
      options = {
        nixpkgs = mkSubmoduleOptions {
          buildPlatform = mkOption {
            type = types.either types.attrs types.str;
            default =
              builtins.seq
              (inputs'.nixpkgs or (throw "flake-parts: The flake does not have a `nixpkgs` input. Please add it, or set `perSystem._module.args.pkgs` yourself."))
              inputs'.nixpkgs.legacyPackages.buildPlatform;
          };
          hostPlatform = mkOption {
            type = types.either types.attrs types.str;
            default =
              builtins.seq
              (inputs'.nixpkgs or (throw "flake-parts: The flake does not have a `nixpkgs` input. Please add it, or set `perSystem._module.args.pkgs` yourself."))
              inputs'.nixpkgs.legacyPackages.hostPlatform;
          };
          path = mkOption {
            type = types.path;
            default =
              builtins.seq
              (inputs'.nixpkgs or (throw "flake-parts: The flake does not have a `nixpkgs` input. Please add it, or set `perSystem._module.args.pkgs` yourself."))
              inputs'.nixpkgs.legacyPackages.path;
            defaultText = "inputs'.nixpkgs.legacyPackges.path";
          };
          # can't be named config since it causes flake-parts to interpret the module differently
          settings = mkOption {
            type = types.attrs;
            default = {};
          };
          overlays = mkOption {
            type = types.listOf overlayType;
            default = [];
          };
        };
      };
      config = {
        _module.args.pkgs = lib.mkOptionDefault (
          import cfg.path {
            inherit (cfg) overlays;
            config = cfg.settings;
            localSystem = cfg.buildPlatform;
            crossSystem = cfg.hostPlatform;
          }
        );
      };
    };
  };
}
