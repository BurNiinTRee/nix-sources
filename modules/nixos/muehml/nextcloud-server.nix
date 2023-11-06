{
  config,
  pkgs,
  ...
}: let
  subdomain = "cloud";
  domain = "${subdomain}.${config.networking.fqdn}";
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    autoUpdateApps.enable = true;
    hostName = domain;
    https = true;
    config = {
      adminpassFile = config.age.secrets.nx-initial-admin-pass.path;
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      defaultPhoneRegion = "SE";
    };
    # We don't use SSE
    enableBrokenCiphersForSSE = false;
    enableImagemagick = true;
    configureRedis = true;
  };

  age.secrets.nx-initial-admin-pass = {
    owner = "nextcloud";
    group = "nextcloud";
    file = ../../secrets/nx-initial-admin-pass.age;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  services.nginx.virtualHosts = {
    ${domain} = {
      enableACME = true;
      forceSSL = true;
    };
    ${config.networking.fqdn} = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/".return = "301 https://${domain}$request_uri";
      };
    };
  };
}
