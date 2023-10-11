{
  pkgs,
  config,
  ...
}: {
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--rt"
      ];
    };
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          config.programs.gamescope.package
          mangohud
        ];
    };
    remotePlay.openFirewall = true;
  };

  programs.gamescope = {
    enable = true;
    args = [
      "--rt"
    ];
    env = {
      INTEL_DEBUG = "noccs";
    };
    capSysNice = true;
  };

  home-manager.users.user = {
    persist.directories = [
      ".config/StardewValley"
      ".local/share/Steam"
    ];
  };
}
