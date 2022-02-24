self: super:
let
  stb = super.stb.overrideAttrs (o: {
    installPhase = o.installPhase + ''
      mkdir -p $out/lib/pkgconfig
      cat > $out/lib/pkgconfig/stb.pc <<'EOF'
      prefix=${builtins.placeholder "out"}
      includedir=''${prefix}/include

      Name: ${o.pname}
      Description: stb single-file public domain libraries for C/C++
      Version: ${o.version}
      Cflags: -I''${includedir}/stb
      EOF
    '';
  });
in
{
  gamescope-new = self.gamescope.overrideAttrs (o: rec {
    version = "3.11.9";
    src = self.fetchFromGitHub {
      owner = "Plagman";
      repo = o.pname;
      rev = version;
      fetchSubmodules = true;
      hash = "sha256-Q5HKfS3ZPj2M3BebLDgjGpAe46e7nKy3AWk4aicucjg=";
    };
    buildInputs = o.buildInputs ++ [ self.wlroots ];
    mesonFlags = o.mesonFlags ++ [ "--force_fallback_for=[]" ];
  });
  gamescope = self.stdenv.mkDerivation rec {
    pname = "gamescope";
    version = "3.9.5";
    src = self.fetchFromGitHub {
      owner = "Plagman";
      repo = pname;
      rev = version;
      sha256 = "sha256-Ih+baHP13IcSaKM7Et9QaLNgZFRiapPPf44YpTgoG1c=";
      fetchSubmodules = true;
    };

    mesonFlags = [ "-Dpipewire=enabled" ];

    nativeBuildInputs = with self; [
      meson
      ninja
      pkg-config
    ];
    buildInputs = with self; [
      glslang
      libcap
      libdrm
      libinput
      libseat
      libudev
      libxkbcommon
      libglvnd
      mesa # for libgbm
      pipewire
      pixman
      SDL2
      stb
      vulkan-loader
      wayland
      wayland-protocols
      xwayland
    ] ++ (with xorg; [
      libX11
      libXcomposite
      libXdamage
      libXext
      libXi
      libXrender
      libXres
      libXtst
      libXxf86vm
      xcbutilwm
      xcbutilerrors
    ]);
  };
}
