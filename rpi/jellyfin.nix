{ config, pkgs, lib, ... }:
{
  services.jellyfin = {
    enable = true;
    group = "media";
  };

  users.users.jellyfin.extraGroups = [ "video" ];

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    defaultListenAddresses = [ "10.99.0.1" "192.168.0.101" ];
    virtualHosts = {
      "rpi.local" = {
        locations."/" = {
          proxyPass = "http://localhost:8096";
        };
      };
    };
  };
}
