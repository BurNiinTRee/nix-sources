{ pkgs, ... }:
{
  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://vault.muehml.eu";
      email = "lars@muehml.eu";
      pinentry = pkgs.pinentry-gnome3;
    };
  };
}
