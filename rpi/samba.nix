{ config, lib, pkgs, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    extraConfig = ''
      guest account = ftp
    '';
    shares.media = {
      path = "/Media";
      "read only" = true;
      browsable = "yes";
      "guest ok" = "yes";
    };
  };

  services.samba-wsdd = {
    enable = true;
  };

  users.users.ftp = {
    isSystemUser = true;
    group = "media";
  };

}
