self: super: {
  rnnoise-plugin = super.rnnoise-plugin.overrideAttrs (old: {
    version = "0.91+476a89c";
    src = super.fetchFromGitHub {
      owner = "werman";
      repo = "noise-suppression-for-voice";
      rev = "476a89cd5acfdacfbce21729292839738cdbc3b8";
      sha256 = "sha256-edQIcXuhudo0XvszvXpBACfmJosJ/98w7bF2MhTDTRY=";
    };
  });
}
