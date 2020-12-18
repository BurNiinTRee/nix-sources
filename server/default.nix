{ pkgs, config, ... }: {
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

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsubAF9SruRBOTXRI2nPAMX5I0gD1OOheji91/NGknv lars@install" ];

  imports = [ ./hardware-configuration.nix ./configuration.nix ];
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
