{pkgs, ...}: {
  home.packages = [
    pkgs.rclone
  ];

  systemd.user.services.nextcloud_mount = {
    Unit = {
      Description = "mount nextcloud";
      After = ["network-online.target"];
    };
    Install.WantedBy = ["default.target"];
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/user/nextcloud";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount cloud.muehml.eu: /home/user/nextcloud \
          --dir-cache-time 48h \
          --vfs-cache-mode full \
          --vfs-cache-max-age 48h \
          --vfs-read-chunk-size 10M \
          --vfs-read-chunk-size-limit 512M \
          --buffer-size 512M
      '';
      ExecStop = "/run/wrappers/bin/fusermount -u /home/user/nextcloud";
      Type = "notify";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
