{ config, lib, ... }:
{
  programs.thunderbird = lib.mkIf config.muehml.guiApps {
    enable = true;
    profiles.user.isDefault = true;
  };
}
