{pkgs, ...}: {
  home.packages = [
    pkgs.keepassxc
  ];

  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeepassXC";
      RequiresMountsFor = "/home/user/nextcloud";
    };
    Service = {
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      BusName = "org.freedesktop.secrets";
      Restart = "always";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
