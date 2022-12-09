self: super: {
  wev = super.wev.overrideAttrs (old: {
    patches = [../patches/wev.patch];
  });
}
