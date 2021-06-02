self: super: {
  htop-unwrapped = super.htop.overrideAttrs (old: {
    pname = "htop-unwrapped";
    buildInputs = old.buildInputs ++ [
      self.lm_sensors
    ];
  });
  htop = self.stdenv.mkDerivation {
    pname = "htop";
    version = self.htop-unwrapped.version;
    src = null;
    phases = [ "buildPhase" ];
    buildInputs = [ self.makeWrapper ];
    buildPhase = ''
      mkdir -p $out/bin/
      ln -s ${self.htop-unwrapped}/bin/htop $out/bin/htop
      wrapProgram $out/bin/htop --suffix LD_LIBRARY_PATH : ${self.lm_sensors}/lib/
    '';
  };
}
