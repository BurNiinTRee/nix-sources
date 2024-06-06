{...}: {
  networking.hostName = "work-laptop";
  wsl.enable = true;
  wsl.defaultUser = "user";
  imports = [
    ../user.nix
    ../nix.nix
  ];
}
