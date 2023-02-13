{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ./configuration.nix
    # ./hardware-configuration.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    ./sound.nix
    ./disko.nix
    ./impermanence.nix
  ];
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
    nixPath = ["nixpkgs=/etc/nixpkgs/"];
  };
  environment.etc."nixpkgs".source = pkgs.path;
  nixpkgs.config = {
    allowUnfree = true;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
