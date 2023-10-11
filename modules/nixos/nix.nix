{
  lib,
  pkgs,
  selfLocation,
  ...
}: {
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
      auto-optimise-store = true;
    };
    nixPath = ["nixpkgs=/etc/nixpkgs/"];
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  environment.etc."nixpkgs".source = pkgs.path;
  environment.etc."nixos/flake.nix".source = pkgs.runCommandLocal "flake-symlink" {} ''
    ln -s ${lib.escapeShellArg selfLocation}/flake.nix $out
  '';
}
