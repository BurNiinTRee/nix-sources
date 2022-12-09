{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.noip];
  systemd.services.noip = {
    enable = true;
    serviceConfig.Type = "forking";
    path = [pkgs.noip];
    script = ''
      noip2 -c /etc/no-ip2.conf -d
    '';
  };
}
