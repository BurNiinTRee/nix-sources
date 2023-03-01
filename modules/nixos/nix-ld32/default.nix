{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  cfg = config.programs.nix-ld;
  # nix-ld32 = pkgs.callPackage ./wrapper.nix {
  #   nix-ld = cfg.package;
  # };
  nix-ld32 = cfg.package.overrideAttrs (old: {
    mesonFlags = ["-Dnix-system=i686-linux"];
  });
  nix-ld32-so = pkgs.runCommand "ld.so" {} ''
    ln -s "$(cat '${pkgs.pkgsi686Linux.stdenv.cc}/nix-support/dynamic-linker')" $out
  '';
  nix-ld32-libraries = pkgs.buildEnv {
    name = "ld32-library-path";
    pathsToLink = ["/lib"];
    paths = map lib.getLib cfg.libraries32Bit;
    extraPrefix = "/share/nix-ld32";
    ignoreCollisions = true;
  };
in {
  options.programs.nix-ld = {
    enable32BitSupport = lib.mkEnableOption "support for 32-bit applications";
    package32Bit = lib.mkOption {
      type = lib.types.package;
    };
    libraries32Bit = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs.pkgsi686Linux; [
        glibc
        stdenv.cc.cc
      ];
    };
  };
  config = lib.mkIf config.programs.nix-ld.enable32BitSupport {
    systemd.tmpfiles.packages = [cfg.package32Bit];
    environment.systemPackages = [nix-ld32-libraries];

    environment.pathsToLink = ["/share/nix-ld32"];

    environment.variables = {
      NIX_LD_i686-linux = toString nix-ld32-so;
      NIX_LD_LIBRARY_PATH_i686-linux = "/run/current-system/sw/share/nix-ld32/lib";
    };
  };
}
