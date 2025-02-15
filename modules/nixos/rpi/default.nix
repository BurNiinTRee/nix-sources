{ ... }:
{
  imports = [
    ./configuration.nix
    ../nix.nix
    ../user.nix
    ./adguard.nix
    ./sound.nix
  ];
}
