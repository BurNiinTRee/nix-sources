{
  config,
  pkgs,
  ...
}: let
  subdomain = "paperless";
in {
  impermanence.directories = [config.services.paperless.dataDir];

  services.paperless = {
    enable = true;
    settings = {
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_OCR_LANGUAGE = "deu+eng+swe";
      PAPERLESS_URL = "https://${subdomain}.${config.networking.fqdn}";
    };
  };

  environment.systemPackages = [pkgs.cifs-utils];
  fileSystems.${config.services.paperless.mediaDir} = {
    device = "//u412961-sub2.your-storagebox.de/u412961-sub2";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,seal,rw,uid=paperless,gid=paperless,dir_mode=0770";
    in ["${automount_opts},credentials=${config.age.secrets.storage-box-paperless.path}"];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["paperless"];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx.virtualHosts."${subdomain}.${config.networking.fqdn}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${toString config.services.paperless.address}:${toString config.services.paperless.port}";
    };
  };

  age.secrets.storage-box-paperless = {
    file = ../../secrets/storage-box-paperless.age;
  };
}
