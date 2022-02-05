{ config, pkgs, lib, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    defaultListenAddresses = [ "10.0.0.1" "192.168.0.105" ];
    virtualHosts = {
      "rpi.local" = {
        locations."/" = {
          proxyPass = "http://localhost:8096";
        };
      };
    };
  };
}
