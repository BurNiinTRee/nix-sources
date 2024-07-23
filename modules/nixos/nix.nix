{
  config,
  pkgs,
  ...
}: {
  age.identityPaths = ["/home/user/.ssh/id_ed25519"];
  age.secrets.netrc-larstop2.file = ../secrets/netrc-larstop2.age;
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      netrc-file = config.age.secrets.netrc-larstop2.path;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://attic.muehml.eu/ci"
      ];
      trusted-public-keys = ["ci:pGN5GUIYtBiawlMyFIapGrGbUT8N1misYuS6iW90neU="];
      trusted-users = ["@wheel"];
      auto-optimise-store = true;
    };
    nixPath = ["nixpkgs=/etc/nixpkgs/"];
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  environment.etc."nixpkgs".source = pkgs.path;
  environment.systemPackages = [pkgs.attic-client];
}
