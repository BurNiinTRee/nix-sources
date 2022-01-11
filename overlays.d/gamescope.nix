self: super: {
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
  gamescope = self.stdenv.mkDerivation rec {
    pname = "gamescope";
    version = "3.10.3";
    src = self.fetchFromGitHub {
      owner = "Plagman";
      repo = pname;
      rev = version;
      sha256 = "sha256-Kg+VhAWrQhOiEHqEJVI9M0Ku//wI5IHD+nNnb/DWHas=";
      fetchSubmodules = true;
    };

    mesonFlags = [ "-Dpipewire=enabled" ];

    # patchPhase = ''
    #   cp -r ${self.stb.src} subprojects/stb
    # '';

    # dontFixCmake = true;
    # dontUseCmakeConfigure = true;


    nativeBuildInputs = with self; [
      # cmake
      meson_0_60
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
      mesa
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
