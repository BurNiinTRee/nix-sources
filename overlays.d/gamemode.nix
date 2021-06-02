self: super: {
  libinih = self.stdenv.mkDerivation rec {
    pname = "libinih";
    version = "r53";

    src = self.fetchFromGitHub {
      owner = "benhoyt";
      repo = "inih";
      rev = version;
      sha256 = "sha256-hi29V40q3c3IvPH7eH3q3z1PiNN59Y0zMhgSroUsDjc=";
    };

    buildInputs = with self; [ meson ninja ];

    mesonFlags = ''
      -Ddefault_library=shared
      -Ddistro_install=true
    '';

  };
  gamemode = self.stdenv.mkDerivation rec {
    pname = "gamemode";
    version = "1.6.1";

    src = self.fetchFromGitHub {
      owner = "FeralInteractive";
      repo = "gamemode";
      rev = version;
      sha256 = "sha256-P00OnZiPZyxBu9zuG+3JNorXHBhJZy+cKPjX+duZrJ0=";
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
