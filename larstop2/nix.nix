{pkgs, ...}: {
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = ["nix-command" "flakes"];

      trusted-users = ["@wheel"];
    };
    nixPath = ["nixpkgs=/etc/nixpkgs/"];
  };
  environment.etc."nixpkgs".source = pkgs.path;
  nixpkgs.config = {
    allowUnfree = true;
  };
}
