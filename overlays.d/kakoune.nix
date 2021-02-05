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

  kak-digraphs = self.stdenv.mkDerivation {
    name = "kakoune-digraphs";
    version = "2018-12-11";
    src = self.fetchFromGitHub {
      owner = "ftonneau";
      repo = "digraphs.kak";
      rev = "d30050485a7790c3a4f4302cee21f17d9e44fc79";
      sha256 = "sha256-XQMC49YsRhAf3A7UfWhGPqvsE9CdfUDzbttSeM+S8V4=";
    };
    installPhase = ''
      install -Dt $out/share/kak/autoload/plugins digraphs.dat digraphs.kak
    '';
  };

  kak-lsp = super.rustPlatform.buildRustPackage rec {
    pname = "kak-lsp";
    version = "9.0.0";

    src = self.fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      sha256 = "1wfv2fy5ga6kc51zka3pak0hq97csm2l11bz74w3n1hrf5q9nnf8";
    };

    cargoSha256 = "0g67s6n45rxvv1q5s7x5ajh5n16p68bhlsrsjp46qamrraz63d68";

    buildInputs = self.lib.optional self.stdenv.isDarwin [ self.darwin.apple_sdk.frameworks.Security ];

    meta = with self.lib; {
      description = "Kakoune Language Server Protocol Client";
      homepage = "https://github.com/ul/kak-lsp";
      license = with licenses; [ unlicense /* or */ mit ];
      maintainers = [ maintainers.spacekookie ];
    };
  };
}
