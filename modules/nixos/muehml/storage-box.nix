{
  config,
  pkgs,
  ...
}: {
  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [pkgs.cifs-utils];
  fileSystems."/mnt/storage-box" = {
    device = "//u412961.your-storagebox.de/backup";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=${config.age.secrets.storage-box.path}"];
  };

  age.secrets.storage-box = {
    file = ../../secrets/storage-box.age;
  };
}
