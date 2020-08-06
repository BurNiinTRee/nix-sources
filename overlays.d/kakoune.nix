self: super:
let sources = import ../nix/sources.nix;
in {
  kakoune-unwrapped = super.kakoune-unwrapped.overrideAttrs (attrs: rec {
    version = "2020-08-06";
    src = sources.kakoune;
    preConfigure = ''
      export version="v${version}"
    '';
  });

  kak-lsp = self.rustPlatform.buildRustPackage {
    pname = "kak-lsp";
    version = "2020-08-06";

    src = sources.kak-lsp;

    cargoSha256 = "0000000000000000000000000000000000000000000000000000";

    meta = with self.lib; {
      description = "Kakoune Language Server Protocol Client";
      homepage = "https://github.com/ul/kak-lsp";
      license = with licenses; [ unlicense /* or */ mit ];
      maintainers = [ maintainers.spacekookie ];
      platforms = platforms.all;
    };
  };
}
