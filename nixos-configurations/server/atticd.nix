{
  pkgs,
  config,
  ...
}: let
  localAtticPort = 2348;
  atticDomain = "attic.muehml.eu";
in {
  services.atticd = {
    enable = true;
    credentialsFile = config.age.secrets."atticd.env".path;

    settings = {
      listen = "127.0.0.1:${builtins.toString localAtticPort}";
      api-endpoint = "https://${atticDomain}/";
      database.url = "postgres:///run/postgresql/.s.PGSQL.5432?dbname=attic";
      chunking = {
        nar-size-threshold = 65536;
        min-size = 16384;
        avg-size = 65536;
        max-size = 26144;
      };
      compression.type = "zstd";
    };
  };
  services.postgresql = {
    ensureDatabases = ["attic"];
    ensureUsers = [
      {
        name = "atticd";
        ensurePermissions = {
          "DATABASE attic" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  services.nginx.virtualHosts.${atticDomain} = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:${builtins.toString localAtticPort}";
    extraConfig = "client_max_body_size 512M;";
  };
  age.secrets."atticd.env".file = ../../secrets/atticd.env.age;
}
