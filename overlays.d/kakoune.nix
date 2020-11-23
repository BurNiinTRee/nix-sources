self: super:
{
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
