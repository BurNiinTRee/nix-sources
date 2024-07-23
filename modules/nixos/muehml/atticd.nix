{config, pkgs, ...}: let
  subdomain = "attic";
in {
  services.atticd = {
    enable = true;
    credentialsFile = config.age.secrets.attic-credentials.path;
    settings = {
      listen = "[::]:43234";
      allowed-hosts = "${subdomain}.${config.networking.fqdn}";
      database.url = "/run/postgresql";
    };
  };

  environment.systemPackages = [pkgs.cifs-utils];
  fileSystems.${config.services.atticd.settings.storage.path} = {
    device = "//u412961-sub3.your-storagebox.de/u412961-sub3";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,seal,rw,uid=${config.services.atticd.user},gid=${config.services.atticd.group},dir_mode=0770";
    in ["${automount_opts},credentials=${config.age.secrets.storage-box-attic.path}"];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [config.services.atticd.user];
    ensureUsers = [
      {
        name = config.services.atticd.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx.virtualHosts."${subdomain}.${config.networking.fqdn}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${toString config.services.atticd.settings.listen}";
    };
  };

  age.secrets = {
    attic-credentials = {
      file = ../../secrets/attic-credentials.age;
      owner = config.services.atticd.user;
      group = config.services.atticd.group;
    };

    storage-box-attic = {
      file = ../../secrets/storage-box-attic.age;
    };
  };
}
