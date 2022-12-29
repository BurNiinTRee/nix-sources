# Taken almost verbatim from Idesgoui at https://github.com/hercules-ci/flake-parts/issues/35
{
  config,
  inputs,
  ...
}: let
  rootConfig = config;
in {
  perSystem = {
    config,
    lib,
    system,
    moduleType,
    ...
  }: {
    # this modules requires our own nixpkgs module, since it allows for adding to the nixpkgs config
    imports = [./nixpkgs.nix];
    options = let
      inherit (lib) mkOption types;
    in {
      crossSystems = mkOption {
        type = types.listOf (types.oneOf [types.str types.attrs]);
        default = builtins.filter (c: system != c && config.selectCrossSystem c) rootConfig.systems;

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
  };
}
