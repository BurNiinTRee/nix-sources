{
  config,
  pkgs,
  lib,
  flakeInputs,
  selfLocation,
  ...
}: {
  imports = [
    ./email.nix
  ];
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # We move the direnv cache to the ~/.cache directory
  # This predominantly helps with .envrc:s in rclone mounts, as these
  # don't allow symlinks, but use_flake tries to create some
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
  programs.password-store = {
    enable = true;
    # We use fedoras password-store
    # but we still want home-managers configuration
    # in particular $PASSWORD_STORE_DIR
    package = pkgs.empty;
  };
  programs.starship.enable = true;
  programs.skim.enable = true;
  programs.htop.enable = true;
  programs.helix = {
    enable = true;
    languages = [
      {
        name = "nix";
        formatter.command = "alejandra";
      }
    ];
    settings.theme = "onelight";
  };

  programs.nushell.enable = true;

  programs.nix-index.enable = true;
  # Download index
  home.file.".cache/nix-index/files" = {
    source = flakeInputs.nix-index-db;
  };
  home.packages = with pkgs; [
    alejandra
    fd
    nil
    nixUnstable
    ripgrep
    # the manpages include configuration.nix(5) which I care about
    ((pkgs.nixos {}).config.system.build.manual.manpages)
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "us+altgr-intl"])
      ];
      xkb-options = ["caps:escape"];
    };
  };

  home.sessionVariables = {
    EDITOR = "hx";
    ## Wayland for Elecron apps
    ## broken as of 22-12-18
    # NIXOS_OZONE_WL = 1;
    ## Rust and Rustup in $XDG_DATA_HOME
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "${config.home.sessionVariables.CARGO_HOME}/bin"
  ];

  home.file.".latexmkrc".text = ''
    $pdf_previewer = 'flatpak run org.gnome.Evince';
  '';

  home.file.".nixpkgs".source = pkgs.path;
  home.sessionVariables.NIX_PATH = "nixpkgs=${config.home.homeDirectory}/.nixpkgs:bntr=${selfLocation}";
  nix = {
    registry = {
      nixpkgs = {
        exact = false;
        to = {
          type = "github";
          owner = "nixos";
          repo = "nixpkgs";
          rev = flakeInputs.nixpkgs.rev;
        };
      };

      bntr.to = {
        url = "file://" + selfLocation;
        type = "git";
      };
      flake-parts.to = {
        type = "github";
        owner = "hercules-ci";
        repo = "flake-parts";
      };
    };

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
      netrc-file = "${config.home.homeDirectory}/.config/nix/netrc";
    };
  };
  xdg.configFile."nixpkgs/flake.nix".source = config.lib.file.mkOutOfStoreSymlink (selfLocation + "/flake.nix");
  home = {
    stateVersion = "23.05";
  };
}
