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
    ./impermanence.nix
    ./nushell.nix
    ./password-store.nix
    ./ssh.nix
    ./reaper.nix
  ];
  persist.directories = [
    "bntr"
    "projects"
    ".cache/nix"
  ];

  fonts.fontconfig.enable = true;

  programs.gh.enable = true;

  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.skim.enable = true;
  programs.htop.enable = true;
  programs.helix = {
    enable = true;
    languages.language = [
      {
        name = "nix";
        formatter.command = "alejandra";
      }
      {
        name = "rust";
        config.check.command = "clippy";
      }
      {
        name = "blueprint";
        file-types = ["blp"];
        indent = {
          tab-width = 2;
          unit = " ";
        };
        scope = "text.blp";
        roots = ["meson.build"];
        comment-token = "//";
        language-server = {
          command = "blueprint-compiler";
          args = ["lsp"];
        };
      }
    ];
    settings.theme = "onelight";
  };
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "nu";
      theme = "catppuccin-latte";
      themes = {
        gruvbox-light = {
          fg = [60 56 54];
          bg = [251 82 75];
          black = [40 40 40];
          red = [205 75 69];
          green = [152 151 26];
          yellow = [215 153 33];
          blue = [69 133 136];
          magenta = [177 98 134];
          cyan = [104 157 106];
          white = [213 196 161];
          orange = [214 93 14];
        };
        catppuccin-latte = {
          bg = "#acb0be"; # Surface2
          fg = "#acb0be"; # Surface2
          red = "#d20f39";
          green = "#40a02b";
          blue = "#1e66f5";
          yellow = "#df8e1d";
          magenta = "#ea76cb"; # Pink
          orange = "#fe640b"; # Peach
          cyan = "#04a5e5"; # Sky
          black = "#4c4f69"; # Text
          white = "#dce0e8"; # Crust
        };

        catppuccin-frappe = {
          bg = "#626880"; # Surface2
          fg = "#c6d0f5";
          red = "#e78284";
          green = "#a6d189";
          blue = "#8caaee";
          yellow = "#e5c890";
          magenta = "#f4b8e4"; # Pink
          orange = "#ef9f76"; # Peach
          cyan = "#99d1db"; # Sky
          black = "#292c3c"; # Mantle
          white = "#c6d0f5";
        };

        catppuccin-macchiato = {
          bg = "#5b6078"; # Surface2
          fg = "#cad3f5";
          red = "#ed8796";
          green = "#a6da95";
          blue = "#8aadf4";
          yellow = "#eed49f";
          magenta = "#f5bde6"; # Pink
          orange = "#f5a97f"; # Peach
          cyan = "#91d7e3"; # Sky
          black = "#1e2030"; # Mantle
          white = "#cad3f5";
        };

        catppuccin-mocha = {
          bg = "#585b70"; # Surface2
          fg = "#cdd6f4";
          red = "#f38ba8";
          green = "#a6e3a1";
          blue = "#89b4fa";
          yellow = "#f9e2af";
          magenta = "#f5c2e7"; # Pink
          orange = "#fab387"; # Peach
          cyan = "#89dceb"; # Sky
          black = "#181825"; # Mantle
          white = "#cdd6f4";
        };
      };
    };
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  home.packages = with pkgs; [
    alejandra
    bottles
    distrobox
    fd
    fira-code
    nil
    qpwgraph
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
        path = selfLocation + "/inner";
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
