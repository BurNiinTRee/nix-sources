{ config, lib, ... }:
{
  programs.ghostty = lib.mkIf config.muehml.guiApps {
    enable = true;
    settings = {
      command = [ "nu" ];
      gtk-adwaita = true;
      font-family = "Fira Code";
      theme = "light:Monokai Pro Light,dark:Monokai Pro";
    };
  };
}
