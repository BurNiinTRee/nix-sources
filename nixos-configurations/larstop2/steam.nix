{...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  home-manager.users.user = {
    persist.directories = [
      ".config/StardewValley"
      ".local/share/Steam"
    ];
  };
}
