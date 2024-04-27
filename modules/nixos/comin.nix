{selfLocation, ...}: {
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/BurNiinTRee/nix-sources.git";
      }
      {
        name = "local";
        url = selfLocation;
        poller.period = 2;
      }
    ];
  };
}
