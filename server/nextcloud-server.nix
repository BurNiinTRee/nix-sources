{ config, pkgs, ... }:
let domain = "cloud.muehml.eu";
in
{
  imports = [ ../modules/nextcloud.nix ];
  disabledModules = [ "services/web-apps/nextcloud.nix" ];
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud20;
    autoUpdateApps.enable = true;
    hostName = domain;
    https = true;
    config = {
      adminpass = "password";
    };
  };
}
