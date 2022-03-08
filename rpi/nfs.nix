{ config, pkgs, lib, ...}:
{
  services.nfs = {
    server = {
      enable = true;
      exports = ''
        /Media 10.99.0.2(rw,all_squash,anonuid=995,anongid=993)
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [ 2049 ];
}