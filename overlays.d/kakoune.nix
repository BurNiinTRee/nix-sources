self: super:
let kak-version = "2020-10-10";
in
{
  kakoune-unwrapped = super.kakoune-unwrapped.overrideAttrs (attrs: rec {
    version = kak-version;
    src = self.kakoune-src;
    preConfigure = ''
      export version="v${version}"
    '';
  });

  kak-lsp = self.stdenv.mkDerivation rec {
    pname = "kak-lsp";
    version = kak-version;

    src = self.kak-lsp-src;

    buildInputs = [
      (self.import-cargo.builders.importCargo {
        lockFile = src + "/Cargo.lock";
        pkgs = self;
      }).cargoHome

      self.rustc
      self.cargo
    ];

    buildPhase = ''
      cargo build --offline --release
    '';
    installPhase = ''
      install -Dm775 ./target/release/kak-lsp $out/bin/kak-lsp
    '';

    meta = with self.lib; {
      description = "Kakoune Language Server Protocol Client";
      homepage = "https://github.com/ul/kak-lsp";
      license = with licenses; [ unlicense /* or */ mit ];
      maintainers = [ maintainers.spacekookie ];
      platforms = platforms.all;
    };
  };


  kak-surround = self.stdenv.mkDerivation {
    name = "kakoune-surround";
    version = "2018-09-17";
    src = self.fetchFromGitHub {
      owner = "h-youhei";
      repo = "kakoune-surround";
      rev = "efe74c6f434d1e30eff70d4b0d737f55bf6c5022";
      sha256 = "sha256-0PicMTkYRnhtrFAMWVgynE4HfoL9/EHZIu4rTSE+zSU=";
    };
    installPhase = ''
      mkdir -p $out/share/kak/autoload/plugins
      cp -r surround.kak $out/share/kak/autoload/plugins/surround.kak
    '';
  };

  kak-cargo = self.stdenv.mkDerivation {
    name = "kakoune-cargo";
    version = "2018-12-11";
    src = self.fetchFromGitLab {
      owner = "Screwtapello";
      repo = "kakoune-cargo";
      rev = "a9047d698658930cd57537ccc39b65546b4a4136";
      sha256 = "sha256-xFl8eVa/o1c9uk/aMbZxz2Tj/clBulsJU40hSRmJFQQ=";
    };
    installPhase = ''
      install -D cargo.kak $out/share/kak/autoload/plugins/cargo.kak
    '';
  };
}
