{
  pkgs,
  lib,
  ...
}: {
  services.xserver.enable = true;

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
    };
    desktopManager.gnome.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };

  services.gnome = {
    # gnome-initial-setup.enable = lib.mkForce false;
    gnome-keyring.enable = lib.mkForce false;
  };

  programs.geary.enable = false;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
  ];
  services.flatpak.enable = true;
}
