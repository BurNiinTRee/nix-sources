{ config, pkgs, ... }:
{

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  home.packages = with pkgs; [
    nil
    nixpkgs-fmt
  ];


  nix.registry.pkgs = {
    from = { id = "pkgs"; type = "indirect"; };
    to = { path = "/var/home/user/nix-sources"; type = "path"; };
  };

  home = {
    username = "user";
    homeDirectory = "/var/home/user";

    stateVersion = "22.11";
  };
}
