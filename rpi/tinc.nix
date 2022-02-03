{ config, pkgs, lib, ... }:
{
  imports = [ ../tinc-hosts.nix ];
  networking.firewall.allowedTCPPorts = [ 655 ];
  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.interfaces."tinc.home".ipv4.addresses = [{
    address = "10.0.0.1";
    prefixLength = 24;
  }];
  services.tinc.networks = {
    home = {
      name = "rpi";
      listenAddress = "192.168.0.105";
    };
  };
}
