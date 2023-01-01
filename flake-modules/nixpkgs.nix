# Taken almost verbatim from Idesgoui at https://github.com/hercules-ci/flake-parts/issues/35
# and upstream flake-parts at https://github.com/hercules-ci/flake-parts/blob/main/modules/nixpkgs.nix
{
  flake-parts-lib,
  config,
  inputs,
  ...
}: let
  rootConfig = config;
  inherit (flake-parts-lib) mkPerSystemOption;
in {
  options.perSystem = mkPerSystemOption ({
    config,
    lib,
    system,
    moduleType,
    inputs',
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
      crossSystems = mkOption {
        type = types.listOf (types.oneOf [types.str types.attrs]);
        default = builtins.filter (c: system != c && config.selectCrossSystem c) (map lib.systems.elaborate rootConfig.systems);

        apply = systems: builtins.map lib.systems.elaborate systems;
      };

      selectCrossSystem = mkOption {
        type = types.functionTo types.bool;

        default = crossSystem: let
          local = lib.systems.elaborate system;
        in
          # Can only build MacOS stuff from MacOS
          (crossSystem.isMacOS -> local.isMacOS)
          # https://github.com/NixOS/nixpkgs/issues/137877
          && (local.isMacOS && local.isAarch64 -> !crossSystem.isLinux);
      };

      x = mkOption {
        type = types.lazyAttrsOf moduleType;
        default = {};
      };
    };

    config = {
      # We set the pkgs arg with a priority of one more than the one set in upstream flake-parts
      _module.args.pkgs = lib.mkOverride ((lib.mkOptionDefault {}).priority - 1) (
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
      nixpkgs.hostPlatform =
        lib.mkIf (config ? _module.args.crossSystem)
        config._module.args.crossSystem;

      x =
        lib.mkIf (!(config ? _module.args.crossSystem))
        (lib.listToAttrs (builtins.map
          (c: {
            name = c.system;
            value = {_module.args.crossSystem = c;};
          })
          config.crossSystems));
    };
  });
}
