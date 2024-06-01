{
  config,
  pkgs,
  ...
}: let
  domain = "cloud.${config.networking.fqdn}";
in {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    autoUpdateApps.enable = true;
    hostName = domain;
    https = true;
    settings = {
      default_phone_region = "SE";
    };
    config = {
      adminpassFile = config.age.secrets.nx-initial-admin-pass.path;
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
    };
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
        ensureDBOwnership = true;
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
    # ${config.networking.fqdn} = {
    #   forceSSL = true;
    #   enableACME = true;
    #   locations = {
    #     "/".return = "301 https://${domain}$request_uri";
    #   };
    # };
  };
}
