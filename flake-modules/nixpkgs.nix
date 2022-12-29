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
        nixpkgs = {
          buildPlatform = mkOption {
            type = types.either types.attrs types.str;
            default =
              inputs'.nixpkgs.legacyPackages.buildPlatform;
          };
          hostPlatform = mkOption {
            type = types.either types.attrs types.str;
            default =
              inputs'.nixpkgs.legacyPackages.hostPlatform;
          };
          path = mkOption {
            type = types.path;
            default =
              inputs'.nixpkgs.legacyPackages.path;
            defaultText = "inputs'.nixpkgs.legacyPackges.path";
          };
          config = mkOption {
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
          import cfg.path ({localSystem = cfg.buildPlatform;}
            // lib.optionalAttrs (cfg.overlays != []) {
              inherit (cfg) overlays;
            }
            // lib.optionalAttrs (cfg.config != {}) {
              config = cfg.config;
            }
            // lib.optionalAttrs (cfg.hostPlatform != cfg.buildPlatform) {
              crossSystem = cfg.hostPlatform;
            })
        );
      };
    };
  };
}
