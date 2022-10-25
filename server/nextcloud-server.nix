{ config, pkgs, ... }:
let domain = "cloud.muehml.eu";
in
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud24;
    autoUpdateApps.enable = true;
    hostName = domain;
    https = true;
    config = {
      adminpassFile = "/etc/nx-pass-file";
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      defaultPhoneRegion = "SE";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      { name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  systemd.services."nextcloud-setup" = {
    requires = [  "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.nginx.virtualHosts = {
    "cloud.muehml.eu" = {
      enableACME = true;
      forceSSL = true;
    };
    "muehml.eu" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/".return = "301 https://cloud.muehml.eu$request_uri";
      };
    };

  };
}
