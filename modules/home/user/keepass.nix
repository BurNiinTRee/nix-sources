{pkgs, ...}: {
  home.packages = [
    pkgs.keepassxc
  ];

  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeepassXC";
    };
    Service = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      BusName = "org.freedesktop.secrets";
      Restart = "always";
      Requires = ["home-user-nextcloud.mount"];
      After = ["home-user-nextcloud.mount"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
