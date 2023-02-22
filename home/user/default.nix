{
  config,
  pkgs,
  lib,
  flakeInputs,
  selfLocation,
  ...
}: {
  imports = [
    ./direnv.nix
    ./email.nix
    ./firefox.nix
    ./git.nix
    ./gnome.nix
    ./gpg.nix
    ./password-store.nix
    ./ssh.nix
  ];
  persist.directories = [
    "bntr"
    "projects"
  ];

  fonts.fontconfig.enable = true;

  programs.bash.enable = true;
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
    fira-code
    nil
    ripgrep
    wl-clipboard
  ];

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
  persist.files = [
    ".config/nix/netrc"
    ".config/attic/config.toml"
  ];

  home = {
    stateVersion = "23.05";
  };
}
