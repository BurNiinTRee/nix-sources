self: super: {
  julia = self.buildFHSUserEnv {
    name = "julia";
    runScript = "julia";
    targetPkgs = pkgs: with pkgs; [
      julia_15
      arrayfire #.overrideAttrs (old: { cmakeFlags = builtins.tail old.cmakeFlags; })
      atk
      at-spi2-atk
      gtk3
      gdk_pixbuf
      glib
      cairo
      pango
      nss
      nspr
      alsaLib
      expat
      libuuid
      dbus
      cups
      gnumake
      unzip
      qt4
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
      libxcb
      libXrandr
      libXScrnSaver
    ]);
  };
}
