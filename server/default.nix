{
  config,
  pkgs,
  lib,
  flakeInputs,
  ...
}: {
  nix = {
    gc = {
      automatic = true;
      dates = "03:00";
      options = "-d";
    };
    optimise = {
      automatic = true;
      dates = ["03:30"];
    };
    nixPath = ["nixpkgs=/etc/nixpkgs"];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nix.registry.nixpkgs = {
    from = {
      id = "nixpkgs";
      type = "indirect";
    };
    flake = flakeInputs.nixpkgs;
  };
  environment.etc."nixpkgs".source = flakeInputs.nixpkgs;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsubAF9SruRBOTXRI2nPAMX5I0gD1OOheji91/NGknv lars@install"];

  imports = [
    ./hardware-configuration.nix
    ./mail-server.nix
    ./nextcloud-server.nix
    # ./pleroma.nix
  ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  environment.systemPackages = [pkgs.htop pkgs.dua pkgs.nix-du];

  security.acme = {
    defaults.email = "lars@muehml.eu";
    acceptTerms = true;
  };

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };
  networking.firewall.allowedTCPPorts = [80 443];

  # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online
  networking = {
    usePredictableInterfaceNames = false;
    hostName = "muehml";
    domain = "eu";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    interfaces."eth0" = {
      ipv6.addresses = [
        {
          address = "2a01:4f8:c17:a38f::1";
          prefixLength = 64;
        }
      ];
      useDHCP = true;
    };
  };
  system.stateVersion = "21.11";
}
