{
  inputs,
  selfLocation,
  ...
}: let
  inherit
    (inputs)
    agenix
    devenv
    treefmt-nix
    ;
in {
  systems = ["x86_64-linux"];
  _module.args.selfLocation = "/home/user/bntr";

  imports = [
    ./flake/nixpkgs.nix
    ./nixos
    ./templates
    devenv.flakeModule
    treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    system,
    self',
    ...
  }: {
    nixpkgs.overlays = [agenix.overlays.default];

    packages = let
      scripts = pkgs.callPackages ./scripts {inherit scripts selfLocation;};
    in
      scripts;

    devenv.shells.default = {
      lib,
      pkgs,
      ...
    }: {
      containers = lib.mkForce {};
      packages =
        [pkgs.agenix pkgs.nixos-rebuild]
        ++ (with self'.packages; [
          update
          deploy
          larstop2
          muehml
          rpi
        ]);
      env.RULES = "${selfLocation}/secrets/secrets.nix";
    };

    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
    };
  };
}
