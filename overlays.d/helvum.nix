self: super: {
  helvum = self.rustPlatform.buildRustPackage rec {
    pname = "helvum";
    version = "git";
    src = self.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "ryuukyu";
      repo = "helvum";
      rev = "24fd54affead16f1ed371935fff2c02ae4a50038";
      sha256 = "sha256-LtcPsde/h9rw6OoZfRlIEtzrMIPJDuYJRm/ncgWCgGM=";
    };

    cargoSha256 = "sha256-pCF7iMlu3Ds8NjUfo895fhzFmVXhxnJ/KPQDoFPITi0=";

    nativeBuildInputs = [
      self.pkg-config
      self.clang
    ];
    buildInputs = [
      self.gtk4
      self.glib
      self.pipewire
    ];

    LIBCLANG_PATH = self.llvmPackages.libclang.lib + "/lib/";
  };
}

