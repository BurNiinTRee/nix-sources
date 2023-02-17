{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    # (modulesPath + "/profiles/qemu-guest.nix")
    ./sound.nix
    ./disko.nix
    ./impermanence.nix
    ./gnome.nix
    ./nix.nix
    ./gl.nix
    ./virtualisation.nix
    ./networking.nix
    ./power.nix
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
