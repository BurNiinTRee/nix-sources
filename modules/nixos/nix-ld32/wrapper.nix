{
  stdenv,
  nix-ld,
  makeWrapper,
  pkgsi686Linux,
  writers,
}: let
  wrapper = writers.writeBash "nix-ld32" ''
    export NIX_LD_LIBRARY_PATH="$NIX_LD32_LIBRARY_PATH"
    export NIX_LD="$NIX_LD32"
    echo NIX_LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    echo NIX_LD=$NIX_LD
    exec ${nix-ld}/libexec/nix-ld
  '';
in
  stdenv.mkDerivation {
    pname = "nix-ld32";
    version = nix-ld.version;

    dontUnpack = true;
    buildPhase = ''
      runHook preBuild

      mkdir -p $out/libexec

      cp ${wrapper} $out/libexec/nix-ld32
      mkdir -p $out/lib/tmpfiles.d/

      ldpath=/lib/$(basename $(< ${pkgsi686Linux.stdenv.cc}/nix-support/dynamic-linker))
      mkdir -p $out/nix-support
      echo "$ldpath" > $out/nix-support/ldpath
      cat > $out/lib/tmpfiles.d/nix-ld32.conf <<EOF
        L+ $ldpath - - - - $out/libexec/nix-ld32
      EOF

      runHook postBuild
    '';
  }
