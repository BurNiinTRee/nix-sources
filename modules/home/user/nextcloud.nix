{pkgs, ...}: {
  home.packages = [
    pkgs.rclone
  ];

  systemd.user.mounts.home-user-nextcloud = {
    Unit = {
      Description = "mount nextcloud";
    };
    Install.WantedBy = ["default.target"];
    Mount = {
      What = "cloud.muehml.eu:";
      Where = "/home/user/nextcloud";
      Type = "rclone";
      Options = "rw,_netdev,args2env,dir-cache-time=48h,vfs-cache-mode=full,vfs-cache-max-age=48h,vfs-read-chunk-size=10M,vfs-read-chunk-size-limit=512M,buffer-size=512M";
    };
  };
}
