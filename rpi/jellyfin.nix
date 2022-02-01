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
    virtualHosts = {
      "rpi.local" = {
        locations."/" = {
          proxyPass = "http://localhost:8096";
        };
      };
    };
  };
}
