{
  description = "Sub flake just exposing modules with no inputs";

  outputs =
    { self }:
    {
      modules = {
        flake = {
          nixpkgs = ./flake/nixpkgs.nix;
        };
      };
      flakeModules.nixpkgs = self.modules.flake.nixpkgs;
    };
}
