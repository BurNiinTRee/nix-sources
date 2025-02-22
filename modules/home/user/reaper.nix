{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.muehml.reaper.enable = lib.mkEnableOption "Reaper" // {
    default = config.muehml.guiApps;
  };

  config = lib.mkIf config.muehml.reaper.enable {
    home.packages = with pkgs; [
      reaper
      # setbfree
    ];
    persist.directories = [ ".config/REAPER" ];
  };
}
