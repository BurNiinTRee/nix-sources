{
  pkgs,
  config,
  ...
}: {
  imports = [./hardware-configuration.nix];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Stockholm";
  # services.xserver = {
  #   enable = true;
  #   desktopManager.gnome.enable = true;
  #   displayManager.gdm = {
  #     enable = true;
  #     wayland = true;
  #   };
  # };

  environment.systemPackages = with pkgs; [
    vim
  ];
  users.users.user = {
    description = "Lars Mühmel";
    isNormalUser = true;
    extraGroups = ["wheel"];
    hashedPassword = "$y$j9T$LP.5L.1fORt5St50tloRb/$gLjp0QteG7YMGpsPjQY/tMtjhVBEhf1lD844Mk3/.SD";
  };
  services.qemuGuest.enable = true;
  # virtualisation.qemu.guestAgent.enable = true;
  system.stateVersion = "23.05";
}
