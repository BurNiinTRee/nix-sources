self: super: {
  julia = self.buildFHSUserEnv {
    name = "julia";
    runScript = ''
      env JULIA_NUM_THREADS=4 CURL_CA_BUNDLE=/etc/ssl/certs/ca-bundle.crt ${self.stdenv.mkDerivation {
      pname = "julia";
      version = self.julia_16-bin.version;
      buildInputs = [ self.qt5.wrapQtAppsHook ];
      dontWrapQtApps = true;
      dontUnpack = true;
      installPhase = ''
        cp -r ${self.julia_16-bin} $out
        chmod +w $out/bin/
        wrapQtApp $out/bin/julia --prefix LD_LIBRARY_PATH : /lib/julia
        chmod -w $out/bin/
      '';
    }}/bin/julia --sysimage /home/lars/nix-sources/julia-stuff/sysimage.so'';

    targetPkgs = pkgs: with pkgs; [
      self.julia_16-bin
      alsaLib
      arrayfire #.overrideAttrs (old: { cmakeFlags = builtins.tail old.cmakeFlags; })
      atk
      at-spi2-atk
      cairo
      cups
      dbus
      electron
      expat
      freetype
      gdk_pixbuf
      glib
      gnumake
      gtk3
      libglvnd
      libnotify
      libpng
      libuuid
      libxkbcommon
      nspr
      nss
      pango
      qt4
      qt5.qtbase
      qt5.qtwayland
      qt5.wrapQtAppsHook
      systemd
      unzip
      zlib

    ] ++ (with xorg; [
      libX11
      libXcursor
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXi
      libXrender
      libXtst
      libXt
      libxcb
      libXrandr
      libXScrnSaver
    ]);
  };
}
