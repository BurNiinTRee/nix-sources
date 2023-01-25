{
  config,
  pkgs,
  flakeInputs,
  selfLocation,
  ...
}: {
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
    package =
      (pkgs.pass.override {
        git = config.programs.git.package;
        openssh = pkgs.empty;
        waylandSupport = true;
      });
      # FIXME this ignores the override we just applied
      # .withExtensions (exts: [exts.pass-otp]);
  };
  programs.git = {
    enable = true;
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

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };
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

  ## EMAIL

  programs.offlineimap = {
    enable = true;
  };
  accounts.email.accounts = let
    pass = acc: "pass show ${acc}";
  in {
    "muehml.eu" = {
      address = "lars@muehml.eu";
      primary = true;
      realName = "Lars Mühmel";
      userName = "lars@muehml.eu";
      imap.host = "mail.muehml.eu";
      passwordCommand = pass "mail.muehml.eu/lars@muehml.eu";
      offlineimap.enable = true;
    };
    "web.de" = {
      address = "larsmuehmel@web.de";
      realName = "Lars Mühmel";
      userName = "larsmuehmel@web.de";
      passwordCommand = pass "web.de/larsmuehmel@web.de";
      imap.host = "imap.web.de";
      offlineimap.enable = true;
    };
    "gmail.com" = {
      address = "lukas.lukas2511@googlemail.com";
      realName = "Lars Mühmel";
      userName = "lukas.lukas2511@googlemail.com";
      imap.host = "imap.gmail.com";
      flavor = "gmail.com";
      offlineimap.enable = true;
      offlineimap.extraConfig.remote = {
        oauth2_client_id_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-id"]).decode()'';
        oauth2_client_secret_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-secret"]).decode()'';
        oauth2_refresh_token_eval = ''get_pass(0,["pass", "show", "google.com/lukas.lukas2511@googlemail.com-email-refresh-token"]).decode()'';
        oauth2_request_url = "https://accounts.google.com/o/oauth2/token";
      };
    };
    "lnu.se" = {
      address = "lm222ux@student.lnu.se";
      realName = "Lars Mühmel";
      userName = "lm222ux@student.lnu.se";
      imap.host = "imap.gmail.com";
      flavor = "gmail.com";
      offlineimap.enable = true;
      offlineimap.extraConfig.remote = {
        oauth2_client_id_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-id"]).decode()'';
        oauth2_client_secret_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-secret"]).decode()'';
        oauth2_refresh_token_eval = ''get_pass(0,["pass", "show", "lnu.se/lm222ux-email-refresh-token"]).decode()'';
        oauth2_request_url = "https://accounts.google.com/o/oauth2/token";
      };
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

  home.file.".nixpkgs".source = flakeInputs.nixpkgs;
  home.sessionVariables.NIX_PATH = "nixpkgs=${config.home.homeDirectory}/.nixpkgs";
  nix = {
    registry = {
      nixpkgs.flake = flakeInputs.nixpkgs;

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
  xdg.configFile."nixpkgs/flake.nix".source = config.lib.file.mkOutOfStoreSymlink (selfLocation + "/flake.nix");
  home = {
    username = "user";
    homeDirectory = "/var/home/user";

    stateVersion = "22.11";
  };
}
