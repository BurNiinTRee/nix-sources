{
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Stockholm";

  environment.systemPackages = with pkgs; [file helix wget];
  environment.variables.EDITOR = "hx";

  users.users.user = {
    description = "Lars Mühmel";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$uybR5rKgVQ5.l/vWvpwYr/$7KxxPR/4ygU2nnKbsEEoH0wh/laRcOgic/yesW2p3P/";
    extraGroups = ["audio" "libvirtd" "kvm" "networkmanager" "video" "wheel"];
  };

  system.fsPackages = [pkgs.rclone];

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  services.sysprof.enable = true;

  system.stateVersion = "23.05";
}
