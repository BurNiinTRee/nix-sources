{
  config,
  pkgs,
  lib,
  ...
}: {

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "wasm32-wasi"
    "x86_64-windows"
  ];

  time.timeZone = "Europe/Stockholm";

  environment.systemPackages = with pkgs; [file helix wget];
  environment.variables.EDITOR = "helix";


  users.users.user = {
    description = "Lars Mühmel";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$uybR5rKgVQ5.l/vWvpwYr/$7KxxPR/4ygU2nnKbsEEoH0wh/laRcOgic/yesW2p3P/";
    extraGroups = ["audio" "libvirtd" "kvm" "networkmanager" "video" "wheel"];
  };

  system.stateVersion = "23.05";
}
