{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    lib = nixpkgs.lib;
  in {
    packages = lib.pipe systems [
      (map (s: {
        name = s;
        value.default = nixpkgs.legacyPackages."${s}".callPackage ./package.nix {};
      }))
      lib.listToAttrs
    ];
  };
}
