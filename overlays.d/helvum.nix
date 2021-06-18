self: super: {
  helvum = self.rustPlatform.buildRustPackage rec {
    pname = "helvum";
    version = "0.2.1";
    src = self.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "ryuukyu";
      repo = "helvum";
      rev = version;
      sha256 = "sha256-ZnpdGXK8N8c/s4qC2NXcn0Pdqrqr47iOWvVwXD9pn1A=";
    };

    cargoSha256 = "sha256-2v2L20rUWftXdhhuE3wiRrDIuSg6VFxfpWYMRaMUyTU=";

    nativeBuildInputs = [
      self.clang
      self.copyDesktopItems
      self.pkg-config
    ];
    buildInputs = [
      self.glib
      self.gtk4
      self.pipewire
    ];

    patches = [ ../patches/helvum-light.patch ];

    desktopItems = self.makeDesktopItem {
      name = "Helvum";
      exec = pname;
      desktopName = "Helvum";
      genericName = "Helvum";
      categories = "AudioVideo;";
      extraEntries = ''
        StartupWMClass=org.freedesktop.ryuukyu.helvum
      '';
    };
    LIBCLANG_PATH = self.llvmPackages.libclang.lib + "/lib/";
  };
}

