{ config, pkgs, lib, ...}:
{
  services.deluge = {
    enable = true;
    group = "media";
    declarative = true;
    dataDir = "/Media";
    authFile = "/etc/deluge-passwd";
    openFirewall = true;
    config = {
      allow_remote = true;
      outgoing_interface = "10.64.0.22";
      listen_interface = "10.64.0.22";
      listen_random_port = 56982;
      listen_ports = [ 56982 ];
    };
  };
  # Open the incoming port and the daemon port
  networking.firewall.allowedTCPPorts = [ 58846 56982 ];
}