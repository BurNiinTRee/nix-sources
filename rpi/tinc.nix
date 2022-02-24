{ config, pkgs, lib, ... }:
{
  imports = [ ../common/tinc-hosts.nix ];
  networking.firewall.allowedTCPPorts = [ 57740 ];
  networking.firewall.allowedUDPPorts = [ 57740 ];
  networking.interfaces."tinc.home".ipv4.addresses = [{
    address = "10.99.0.1";
    prefixLength = 24;
  }];
  services.tinc.networks = {
    home = {
      name = "rpi";
      listenAddress = "0.0.0.0";
      settings = {
        port = 57740;
        Mode = "router";
      };
      
    };
  };
}
