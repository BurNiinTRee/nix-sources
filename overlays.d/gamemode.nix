self: super: {
  libinih = self.stdenv.mkDerivation rec {
      pname = "libinih";
      version = "r52";

      src = self.fetchFromGitHub {
          owner = "benhoyt";
          repo = "inih";
          rev = version;
          sha256 = "sha256-pIaDvCxAY9r5UiutUStI66PC3v7L19hpD3Ev9cmoW1M=";
      };

      buildInputs = with self; [ meson ninja ];

      mesonFlags = ''
        -Ddefault_library=shared
        -Ddistro_install=true
      '';

  };
  gamemode = self.stdenv.mkDerivation rec {
    pname = "gamemode";
    version = "1.6";

    src = self.fetchFromGitHub {
      owner = "FeralInteractive";
      repo = "gamemode";
      rev = version;
      sha256 = "sha256-Ccxarp0f5w2vfzlzqwvGmHF1PKL+A92xDZidEhA2sKQ=";
    };

    buildInputs = with self; [ meson ninja pkgconfig systemd dbus libinih ];

    prePatch = ''
      substituteInPlace daemon/gamemode-tests.c --replace "/usr/bin/gamemoderun" $out/bin/gamemoderun
      substituteInPlace daemon/gamemode-gpu.c --replace "/usr/bin/pkexec" ${self.polkit}/bin/pkexec
      substituteInPlace daemon/gamemode-context.c --replace "/usr/bin/pkexec" ${self.polkit}/bin/pkexec
      substituteInPlace lib/gamemode_client.h --replace 'dlopen("' 'dlopen("${
        placeholder "out"
      }/lib/'
    '';

    postInstall = ''
      substituteInPlace $out/bin/gamemoderun --replace libgamemodeauto.so.0 ${placeholder "out"}/lib/libgamemodeauto.so.0
    '';

    mesonFlags = ''
      -Dwith-examples=false
      -Dwith-systemd-user-unit-dir=${placeholder "out"}/lib/systemd/user
    '';
  };
}
