{
  description = "Sub flake just exposing modules with no inputs";

  outputs = {self}: {
    modules = {
      nixos = {
        larstop2 = ./nixos/larstop2/default.nix;
        muehml = ./nixos/muehml/default.nix;
        htpc = ./nixos/htpc/default.nix;
      };
      home = {
        user = ./home/user/default.nix;
      };
      flake = {
        nixpkgs = ./flake/nixpkgs.nix;
        default = ./self.nix;
      };
    };
  };
}
