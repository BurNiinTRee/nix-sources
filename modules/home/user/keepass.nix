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

  home.file.".local/share/dbus-1/services/keepassxc.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.secrets
    Exec=false
    SystemdService=keepassxc.service
  '';
}
