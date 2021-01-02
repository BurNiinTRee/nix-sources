inputs: { config, pkgs, ... }:
let
  firefox = with pkgs;
    wrapFirefox firefox-unwrapped {
      forceWayland = true;
      extraNativeMessagingHosts = [ browserpass gnomeExtensions.gsconnect ];
      browserName = "firefox";
      pname = "firefox";
      desktopName = "Firefox";
    };
  julia = pkgs.stdenv.mkDerivation {
    inherit (pkgs.julia) name version meta;
    phases = [ "buildPhase" ];
    buildInputs = [ pkgs.makeWrapper ];
    buildPhase = ''
      makeWrapper ${pkgs.julia}/bin/julia $out/bin/julia --prefix LD_LIBRARY_PATH : ${
        pkgs.arrayfire.overrideAttrs (old: { cmakeFlags = builtins.tail old.cmakeFlags; })
      }/lib --prefix PATH : ${pkgs.gnumake}/bin
    '';
  };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  systemd.user.startServices = true;

  home.packages = with pkgs; [
    ardour
    cargo-edit
    dua
    exercism
    fd
    ffmpeg
    file
    fira-code
    firefox
    gcc
    gnome3.gnome-tweaks
    gnomeExtensions.gsconnect
    gnomeExtensions.draw-on-your-screen
    gnomeExtensions.appindicator
    helm
    htop
    inputs.rnix-flake.packages.x86_64-linux.rnix-lsp
    inputs.deploy-rs.defaultPackage.x86_64-linux #.packages.x86_64-linux.nixops
    iftop
    julia
    jupyterlab-rust
    killall
    multimc
    patchage
    pciutils
    pijul
    ripgrep
    rustup
    simple-http-server
    steam
    tab-rs
    thunderbird-78
    tokei
    virtmanager
    wev
    wl-clipboard
    xournalpp
  ];

  programs = {
    bash = {
      enable = true;
      sessionVariables = {
        EDITOR = "kak";
        LV2_PATH = "~/.nix-profile/lib/lv2";
      };
      shellAliases = {
        cat = "bat";
        iftop = "sudo iftop -B -m 10M";
      };
    };

    starship = {
      enable = true;
      settings = {
        status.disabled = false;
        custom.tab = {
          description = "The current tab in the tab terminal multiplexer";
          command = "tab --starship";
          when = "tab --starship";
          format = "[$output]($style)";
          style = "bold blue";
        };
      };
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "nix-lsp";
          publisher = "aaronduino";
          version = "0.0.1";
          sha256 = "sha256-PNXa/rBdXU9jlUdZcKJODU2+f5F53rtezA+lTzvDF6Q=";
        }

        {
          name = "dance";
          publisher = "gregoire";
          version = "0.3.2";
          sha256 = "sha256-+g8EXeCkPOPvZ60JoXkGTeSXYWrXmKrcbUaEfDppdgA=";
        }
      ] ++ (with pkgs.vscode-extensions; [
        matklad.rust-analyzer
      ]);
      userSettings = {
        "update.mode" = "none";
        "keyboard.dispatch" = "keyCode";
        "workbench.colorTheme" = "Default Light+";
        "telemetry.enableTelemetry" = false;
        "telemetry.enableCrashReporter" = false;
        "editor.fontFamily" =
          "Fira Code, 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
        "julia.enableTelemetry" = false;
        "julia.enableCrashReporter" = false;
        "julia.execution.resultType" = "both";
        "julia.NumThreads" = 8;
        "julia.executablePath" = julia + "/bin/julia";
        "terminal.integrated.commandsToSkipShell" =
          [ "language-julia.interrupt" ];
        "python.pythonPath" = "";
        "workbench.editorAssociations" = [{
          "viewType" = "jupyter.notebook.ipynb";
          "filenamePattern" = "*.ipynb";
        }];
      };
    };

    kakoune = {
      enable = true;
      plugins =
        [ pkgs.kakounePlugins.kak-auto-pairs pkgs.kak-cargo pkgs.kak-surround ];
      config = {
        numberLines = {
          enable = true;
          highlightCursor = true;
          relative = true;
        };
        ui.statusLine = "top";
        hooks = [
          {
            name = "KakBegin";
            option = ".*";
            commands = ''set-option global termcmd "gnome-terminal -- sh -c"'';
          }
          {
            name = "WinCreate";
            option = ".*";
            commands = "auto-pairs-enable";
          }
          {
            name = "WinSetOption";
            option = "filetype=rust";
            commands = "lsp-enable-window";
          }
          {
            name = "WinSetOption";
            option = "filetype=nix";
            commands = "set-option window indentwidth 2";
          }
          {
            name = "WinSetOption";
            option = "filetype=latex";
            commands = "hook window BufWritePost .* make";
          }
        ];
        keyMappings = [
          {
            docstring = "LSP Mode";
            effect = ": enter-user-mode lsp<ret>";
            key = "l";
            mode = "user";
          }
          {
            docstring = "Cargo Mode";
            effect = ": enter-user-mode cargo<ret>";
            key = "c";
            mode = "user";
          }
          {
            docstring = "Comment Line";
            effect = ": comment-line<ret>";
            key = "/";
            mode = "user";
          }
          {
            docstring = "surround selection";
            effect = ": surround<ret>";
            key = "s";
            mode = "user";
          }
        ];
        scrollOff.columns = 10;
        scrollOff.lines = 5;
      };
      extraConfig = ''
        define-command ide %{
          rename-client main
          new rename-client tools
          set-option global toolsclient tools
          set-option global jumpclient main
        }
        eval %sh{${pkgs.kak-lsp}/bin/kak-lsp --kakoune -s $kak_session}
      '';
    };

    bat = {
      enable = true;
      config.theme = "Solarized (light)";
    };

    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };

    password-store.enable = true;
    #    browserpass = {
    #      enable = true;
    #      browsers = [ "firefox" ];
    #    };
    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = { pull = { ff = "only"; }; };
      userEmail = "larsmuehmel@web.de";
      userName = "Lars Mühmel";
    };

    gpg.enable = true;
  };

  services = {
    syncthing.enable = true;
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    nextcloud-client.enable = true;
  };

  xdg.configFile."kak-lsp/kak-lsp.toml".text =
    let orig = builtins.readFile (pkgs.kak-lsp.src + "/kak-lsp.toml");
    in builtins.replaceStrings [ "rls" ] [ "rust-analyzer" ] orig;

  xdg.configFile."pijul/config.toml".text = pkgs.lib.generators.toINI {} {
    author = {
      name = ''"BurNiinTRee"'';
      full_name = ''"Lars Mühmel"'';
      email = ''"larsmuehmel@web.de"'';
    };
  };

  xdg.configFile."tab.yml".text = pkgs.lib.generators.toYAML
    { } {
    workspace = [{
      tab = "home";
      directory = "~";
    }
    {
      tab = "nix-sources";
      directory = "~/Sync/nix-sources";
    }];
  };

  home.file =
    let
      dirPath = firefox + "/lib/mozilla/native-messaging-hosts/";
      fileNames = builtins.attrNames (builtins.readDir dirPath);
      files = map
        (n: {
          path = dirPath + n;
          name = n;
        })
        fileNames;
    in
    builtins.foldl'
      (a:
        { name, path }:
        a // {
          ".mozilla/native-messaging-hosts/${name}".source = path;
        }
      )
      { }
      files;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lars";
  home.homeDirectory = "/home/lars";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
