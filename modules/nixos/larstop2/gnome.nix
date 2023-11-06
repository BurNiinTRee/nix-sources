{
  pkgs,
  lib,
  flakeInputs,
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
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
    desktopManager.gnome.enable = true;
  };

  services.gnome = {
    # gnome-initial-setup.enable = lib.mkForce false;
    gnome-keyring.enable = lib.mkForce false;
  };

  programs.geary.enable = false;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnome.nautilus-python
    flakeInputs.nixpkgs-mine.legacyPackages.x86_64-linux.turtle
  ];
  services.flatpak.enable = true;
}
