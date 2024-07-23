{
  config,
  pkgs,
  ...
}: {
  age.secrets.netrc-larstop2.file = ../../secrets/netrc-larstop2;
  nix.settings.netrc-file = config.age.secrets.netrc-larstop2.path;
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      substitutors = [
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
