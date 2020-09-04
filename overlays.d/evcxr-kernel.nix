self: super:
let
  rust-kernel-logos = self.stdenv.mkDerivation {
    name = "rust-kernel-logos";
    buildInputs = [ self.evcxr ];
    phases = [ "buildPhase" "installPhase" ];
    buildPhase = ''
      JUPYTER_CONFIG_DIR=$PWD evcxr_jupyter --install
    '';
    installPhase = ''
      mkdir -p $out/share
      cp kernels/rust/logo-32x32.png $out/share/
      cp kernels/rust/logo-64x64.png $out/share/
    '';
  };
  definitions = {
    rust = {
      displayName = "Rust";
      argv = [
        (self.evcxr + "/bin/.evcxr_jupyter-wrapped")
        "--control_file"
        "{connection_file}"
      ];
      language = "rust";
      logo32 = rust-kernel-logos + "/share/logo-32x32.png";
      logo64 = rust-kernel-logos + "/share/logo-64x64.png";
    };
  };
in {
  jupyterlab-rust =
    self.python38Packages.jupyterlab.overridePythonAttrs (old: {
      makeWrapperArgs = old.makeWrapperArgs ++ [ "--set JUPYTER_PATH ${self.jupyter-kernel.create { inherit definitions; }}" ];
    });
}
