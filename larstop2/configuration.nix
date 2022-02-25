# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./tinc.nix
    ./sound.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.plymouth.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  services.flatpak.enable = true;


  hardware.tuxedo-keyboard.enable = true;
  boot.kernelParams = [
    "tuxedo_keyboard.state=0"
  ];

  # services.thermald.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
  };

  containers = {
    pg.config = { config, pkgs, ... }: {
      services.postgresql = {
        enable = true;
        ensureDatabases = [ "lars" ];
        ensureUsers = [{ name = "lars"; }];
        authentication = ''
          host all all ::1/128 trust
        '';
      };
      users.users.lars.isNormalUser = true;
    };
  };

  # Services for Database Theory
  services.mysql = {
    enable = false;
    package = pkgs.mysql80;
    ensureUsers = [{
      name = "lars";
      ensurePermissions = { "*.*" = "ALL PRIVILEGES"; };
    }];
  };

  # LUKS setup
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  boot.initrd.luks.devices = {
    root = {
      name = "root";
      device = "/dev/disk/by-uuid/924539f8-79ac-4f15-b419-a4219115ee34";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "larstop2"; # Define your hostname.
  services.avahi = {
    enable = true;
    nssmdns = true;
    allowPointToPoint = true;
    interfaces = [ "tinc.home" "enp57s0f1" "wlp58s0" ];
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp57s0f1.useDHCP = true;
  networking.interfaces.wlp58s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ file kakoune vim wget ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # for gsconnect
  networking.firewall.allowedTCPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 1714;
    to = 1764;
  }];

  networking.wireguard.enable = true;

  services.mullvad-vpn.enable = true;
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable GPU
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ vaapiIntel intel-compute-runtime ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.xserver.desktopManager.gnome.enable = true;
  programs.geary.enable = false;

  programs.gamemode = {
    enable = true;
    settings.custom = {
      start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
    };
  };

  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "powersave";
  };
  services.power-profiles-daemon.enable = true;

  programs.cdemu = {
    enable = true;
    group = "video";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lars = {
    description = "Lars Mühmel";
    isNormalUser = true;
    extraGroups = [ "audio" "libvirtd" "kvm" "networkmanager" "video" "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?
}