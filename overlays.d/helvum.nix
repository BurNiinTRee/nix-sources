self: super: {
  helvum = super.helvum.overrideAttrs (old: {
    patches = old.patches or [] ++ [ ../patches/helvum-light.patch ];
  });
}

