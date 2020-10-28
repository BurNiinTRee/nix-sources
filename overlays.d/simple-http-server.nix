self: super: {
  simple-http-server = self.rustPlatform.buildRustPackage rec {
    pname = "simple-http-server";
    version = "0.6.1";
    src = self.fetchFromGitHub {
      owner = "TheWaWar";
      repo = pname;
      rev = "47be2571e58c2def4c713503616464b1096ba2bb";
      sha256 = "sha256-X0nDWQoUl7+YY/gHRcU8VP8qnLRko+qWML6X9fZxF8U=";
    };

    cargoSha256 = "sha256-xiGRlo9mRAlLzp5VtZQhqxBj9C8FF4S5bc+gCOL+7gU=";
  };
}
