{pkgs,...}: {
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        gamescope
        mangohud
      ];
    };
    remotePlay.openFirewall = true;
  };

  home-manager.users.user = {
    persist.directories = [
      ".config/StardewValley"
      ".local/share/Steam"
    ];
  };
}
