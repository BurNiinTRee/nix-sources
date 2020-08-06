self: super:

{
  pipewire-libpulseaudio = self.stdenv.mkDerivation {
    name = "pipewire-libpulseaudio";
    version = super.libpulseaudio.version;
    phases = [ "buildPhase" ];
    buildPhase = ''
      mkdir -p $out/lib
      cp -r ${super.libpulseaudio.dev}/include $out/include
      cp ${self.pipewire.lib}/lib/pipewire-0.3/pulse/* $out/lib/
      cp -r ${super.libpulseaudio.dev}/lib/pkgconfig $out/lib/pkgconfig
      cd $out/lib/pkgconfig
      for f in $(ls -1); do
          substituteInPlace $f --replace ${super.libpulseaudio} $out
          substituteInPlace $f --replace ${super.libpulseaudio.dev} $out
      done
    '';
  };
  pw-pulse = self.stdenv.mkDerivation {
    name = "pw-pulse";
    version = super.pipewire.version;
    phases = [ "buildPhase" ];
    buildPhase = ''
      mkdir -p $out/bin
      cp ${super.pipewire}/bin/pw-pulse $out/bin/pw-pulse
      substituteInPlace $out/bin/pw-pulse --replace "${super.pipewire}" "${super.pipewire.lib}"
    '';
  };
}
