{ config, pkgs, lib, ... }:
{
  imports = [ ../common/tinc-hosts.nix ];
  networking.interfaces."tinc.home".ipv4.addresses = [{ 
    address = "10.99.0.2"; 
    prefixLength = 24;
    }];
  services.tinc.networks = {
    home = {
      name = "larstop2";
      settings = {
        ConnectTo = "rpi";
        Mode = "router";
      };
    };
  };
}
