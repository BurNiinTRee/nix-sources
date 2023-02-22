{pkgs, ...}: {
  services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  xdg.portal = {
    enable = true;
  };

  services.xserver = {
    libinput.enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
    desktopManager.gnome.enable = true;
  };

  programs.geary.enable = false;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
  ];
  services.flatpak.enable = true;
}
