{
  config,
  pkgs,
  flakeInputs,
  ...
}: {
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # We move the direnv cache to the ~/.cache directory
  # This predominantly helps with .envrc:s in rclone mounts, as these
  # don't allow symlinks, but use_nix tries to create some
  xdg.configFile."direnv/lib/cache.sh".text = ''
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    declare -A direnv_layout_dirs
    direnv_layout_dir() {
    	echo "''${direnv_layout_dirs[$PWD]:=$(
    		local hash="$(sha1sum - <<<"''${PWD}" | cut -c-7)"
    		local path="''${PWD//[^a-zA-Z0-9]/-}"
    		echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
    	)}"
    }
  '';

  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.skim.enable = true;
  programs.htop.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };
  programs.nix-index.enable = true;
  # Download index
  home.file.nix-index-db = {
    target = "./.cache/nix-index/files";
    source = flakeInputs.nix-index-db;
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
    EDITOR = "codium -w";
    # Wayland for Elecron apps
    NIXOS_OZONE_WL = 1;
    # Rust and Rustup in $XDG_DATA_HOME
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "${config.home.sessionVariables.CARGO_HOME}/bin"
  ];

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
