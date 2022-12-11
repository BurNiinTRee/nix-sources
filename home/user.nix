{
  config,
  pkgs,
  flakeInputs,
  ...
}: {
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.skim.enable = true;
  programs.htop.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  home.packages = with pkgs; [
    alejandra
    fd
    nil
    ripgrep
    # the manpages include configuration.nix(5) which I care about
    ((pkgs.nixos {}).config.system.build.manual.manpages)
  ];

  home.sessionVariables = {
    EDITOR = "${config.programs.vscode.package}/bin/codium -w";
  };

  nix = {
    registry = {
      nixpkgs.flake = flakeInputs.nixpkgs;

      pkgs.to = {
        path = "/var/home/user/nix-sources";
        type = "path";
      };
      flake-parts.to = {
        type = "github";
        owner = "BurNiinTRee";
        repo = "flake-parts";
      };
    };

    package = pkgs.nixUnstable;

    settings = let
      emptyFlakeRegistry = pkgs.writeText "flake-registry.json" (builtins.toJSON {
        flakes = [];
        version = 2;
      });
    in {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      sandbox = true;
      connect-timeout = 5;
      log-lines = 25;
      min-free = 54534824;
      fallback = true;
      warn-dirty = false;
      auto-optimise-store = true;
      max-jobs = 6;
      flake-registry = emptyFlakeRegistry;
    };
  };
  targets.genericLinux.enable = true;
  home = {
    username = "user";
    homeDirectory = "/var/home/user";

    stateVersion = "22.11";
  };
}
