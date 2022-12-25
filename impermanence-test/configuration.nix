{
  pkgs,
  config,
  modulesPath,
  ...
}: {
  networking.hostName = "impermanent";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "sr_mod"
  ];
  boot.supportedFilesystems = ["ext4" "vfat"];

  imports = [
    ./disko.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
    ];
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

  nix.settings = {
    experimental-features = ["flakes" "nix-command" "repl-flake"];
  };
  services.qemuGuest.enable = true;
  system.stateVersion = "23.05";
}
