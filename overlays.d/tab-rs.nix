self: super: {
  tab-rs = self.rustPlatform.buildRustPackage rec {
    pname = "tab-rs";
    version = "0.5.2";
    src = self.fetchFromGitHub {
      owner = "austinjones";
      repo = pname;
      rev = "v" + version;
      sha256 = "sha256-EaCZXRA3U1Egcp1En3QeS7SZu1dnH3E6+bJ5A/iAPLg=";
    };
    postInstall = ''
      pwd
      install -Dm661 tab/src/completions/bash/tab.bash $out/share/bash-completion/completions/tab.bash
    '';
    doCheck = false;
    buildAndTestSubdir = "tab";

    cargoSha256 = "sha256-7hgvGBHhxJTEu6X16Rz+bubaPojwnRoREZg5fhqCuqI=";
  };
}
