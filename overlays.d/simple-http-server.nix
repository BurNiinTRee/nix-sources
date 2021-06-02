self: super: {
  simple-http-server = self.rustPlatform.buildRustPackage rec {
    pname = "simple-http-server";
    version = "0.6.1";
    nativeBuildInputs = [ self.pkgconfig ];
    buildInputs = [ self.openssl ];
    src = self.fetchFromGitHub {
      owner = "TheWaWar";
      repo = pname;
      rev = "47be2571e58c2def4c713503616464b1096ba2bb";
      sha256 = "sha256-X0nDWQoUl7+YY/gHRcU8VP8qnLRko+qWML6X9fZxF8U=";
    };

    cargoSha256 = "sha256-Wh36WL/YKKQCH21L0VK5EzcZ8r6xAkv0T2PWBJgCLck=";
  };
}
