{
  description = "My very special Rust project";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    import-cargo.url = "github:edolstra/import-cargo";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-utils, import-cargo, nixpkgs, mozilla }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      cargo-vendor = (import-cargo.builders.importCargo {
        lockFile = ./Cargo.lock;
        inherit pkgs;
      });
      buildRelease = isRelease: pkgs.stdenv.mkDerivation {
        pname = "hello";
        version = "0.1.0";
        src = self;
        nativeBuildInputs = [
          cargo-vendor.cargoHome
          pkgs.rustc
          pkgs.cargo
        ];
        buildPhase = ''
          cargo build --offline ${if isRelease then "--release" else ""}
        '';
        installPhase = ''
          install -Dt $out/bin ./target/${if isRelease then "release" else "debug"}/hello
        '';
        shellHook = ''
          unset CARGO_HOME
        '';
      };
    in
    rec {
      packages = {
        debug = buildRelease false;
        release = buildRelease true;
      };
      defaultPackage = packages.release;

    });
}
