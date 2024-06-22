{pkgs, ...}: {
  nix = {
    package = pkgs.nixVersions.stable;
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
}
