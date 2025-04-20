{
  self,
  inputs,
  selfLocation,
  ...
}:
let
  inherit (inputs)
    treefmt-nix
    ;
in
{
  systems = [ "x86_64-linux" ];
  _module.args.selfLocation = "/home/user/bntr";

  imports = [
    ./flake/nixpkgs.nix
    ./home
    ./nixos
    ./templates
    treefmt-nix.flakeModule
  ];

  flake.flakeModules = {
    nixpgks = ./flake/nixpkgs.nix;
  };

  perSystem =
    {
      config,
      pkgs,
      system,
      self',
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nixos-rebuild
          pkgs.sops
        ];
      };

      checks = {
        muehml = self.nixosConfigurations.muehml.config.system.build.toplevel;
        # larstop2 = self.nixosConfigurations.larstop2.config.system.build.toplevel;
        homeManager = self.homeConfigurations.user.config.home.activationPackage;
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };
}
