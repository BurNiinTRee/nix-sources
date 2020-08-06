self: super: {
  wev = super.wev.overrideAttrs (old: {
    patches = [ ~/packages/wev/wev.patch ];
  });
}
