{
  config,
  pkgs,
  lib,
  flakeInputs,
  selfLocation,
  ...
}: {
  imports = [
    ./bitwarden.nix
    ./direnv.nix
    ./eduroam.nix
    ./email.nix
    ./firefox.nix
    ./git.nix
    ./gnome.nix
    ./gpg.nix
    ./helix.nix
    ./impermanence.nix
    ./nextcloud.nix
    ./nushell.nix
    ./password-store.nix
    ./ssh.nix
    ./reaper.nix
    ./zellij.nix
  ];
  persist.directories = [
    "bntr"
    "projects"
    ".cache/nix"
  ];

  fonts.fontconfig.enable = true;

  programs.gh.enable = true;

  programs.bash.enable = true;
  programs.starship = {
    enable = true;
    enableBashIntegration = false;
  };
  programs.htop.enable = true;
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  home.packages = with pkgs; [
    alejandra
    bottles
    denaro
    distrobox
    fd
    fira-code
    intel-gpu-tools
    keepassxc
    libreoffice-fresh
    lsof
    nil
    qpwgraph
    ripgrep
    wl-clipboard
  ];

  home.sessionVariables = {
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

  xdg.configFile."latexmk/latexmkrc".text = ''
    $pdf_previewer = 'xdg-open';
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

      bntr-outer.to = {
        url = "file://" + selfLocation;
        type = "git";
      };
      bntr.to = {
        path = selfLocation + "/modules";
        type = "path";
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
    ".local/share/nix/trusted-settings.json"
  ];

  home = {
    stateVersion = "23.05";
  };
}
