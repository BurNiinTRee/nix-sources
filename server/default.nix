{
  nix = {
    gc = {
      automatic = true;
      dates = "03:00";
      options = "-d";
    };
    optimise = {
      automatic = true;
      dates = [ "03:30" ];
    };
  };

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_ed25519.pub ];

  imports = [ ./hardware-configuration.nix (import ./configuration.nix self) ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  environment.systemPackages = [ pkgs.htop pkgs.dua ];

  # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online
  networking = {
    usePredictableInterfaceNames = false;
    hostName = "matrix-homeserver";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    interfaces."eth0" = {
      ipv6.addresses = [{
        address = "2a01:4f8:c17:a38f::1";
        prefixLength = 64;
      }];
      useDHCP = true;
    };
  };
}
