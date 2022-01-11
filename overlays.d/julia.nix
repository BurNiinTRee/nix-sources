self: super: {
  julia = self.buildFHSUserEnv {
    name = "julia";

    runScript = "julia";

    targetPkgs = pkgs: with pkgs; [
      julia-bin
      alsaLib
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
