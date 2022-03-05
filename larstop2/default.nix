inputs@{ config, pkgs, lib, self, nixpkgs, home-manager, musnix, overlays, ... }:
{
  imports = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
    musnix.nixosModules.musnix
  ];
  system.configurationRevision = lib.mkIf (self ? rev) self.rev;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry.pkgs.to = {
      type = "path";
      path = "/home/lars/nix-sources";
    };
    nixPath = [ "nixpkgs=/etc/nixpkgs/" ];
  };
  environment.etc."nixpkgs".source = nixpkgs;
  nixpkgs.overlays = overlays;
  nixpkgs.config = {
    allowUnfree = true;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit (inputs) reaper rnix-flake modartt; };
  home-manager.users.lars = import ./home.nix;
}
