{...}: {
  config.perSystem = {
    config,
    lib,
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
    };
  };
}
