{
  pkgs,
  lib,
  ...
}: {
  security.rtkit.enable = true;

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        use_mpris = false;
      };
    };
  };
}
