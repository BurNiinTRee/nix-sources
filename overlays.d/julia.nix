self: super: {
  julia = self.buildFHSUserEnv {
    name = "julia";
    runScript = "julia --sysimage /home/lars/nix-sources/julia-stuff/sysimage.so";
    targetPkgs = pkgs: with pkgs; [
      julia_15
      alsaLib
      arrayfire #.overrideAttrs (old: { cmakeFlags = builtins.tail old.cmakeFlags; })
      atk
      at-spi2-atk
      cairo
      cups
      dbus
      expat
      gdk_pixbuf
      glib
      gnumake
      gtk3
      libuuid
      libglvnd
      nspr
      nss
      pango
      qt4
      qt5.qtbase
      qt5.qtwayland
      unzip
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
