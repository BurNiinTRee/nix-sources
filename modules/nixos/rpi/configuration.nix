# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "rpi"; # Define your hostname.

  time.timeZone = "Europe/Stockholm";

  services.avahi = {
    enable = true;
    nssmdns = true;
    allowInterfaces = ["enu1u1"];
    publish = {
      enable = true;
      addresses = true;
    };
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    helix
    htop
    dua
  ];
  environment.sessionVariables = {
    EDITOR = "hx";
  };

  services.openssh.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?
}
