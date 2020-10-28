{ config, pkgs, ... }:
let
  firefox = with pkgs;
    (wrapFirefox firefox-unwrapped {
      forceWayland = true;
      extraNativeMessagingHosts = [ browserpass gnomeExtensions.gsconnect ];
      browserName = "firefox";
      pname = "firefox";
      desktopName = "Firefox";
    });
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  systemd.user.startServices = true;

  home.packages = with pkgs; [
    ardour
    cargo-edit
    dua
    fd
    ffmpeg
    file
    fira-code
    firefox
    flatpak-builder
    gcc
    gnome3.gnome-tweaks
    gnomeExtensions.gsconnect
    gnomeExtensions.draw-on-your-screen
    helm
    htop
    iftop
    jupyterlab-rust
    killall
    niv
    nixfmt
    nixops
    pciutils
    pw-pulse
    qjackctl
    ripgrep
    rustup
    simple-http-server
    steam
    thunderbird-bin-78
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
      };
    };

    kakoune = {
      enable = true;
      plugins = [ pkgs.kakounePlugins.kak-auto-pairs pkgs.kak-cargo pkgs.kak-surround ];
      config = {
        colorScheme = "gruvbox";
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

    bat.enable = true;

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
  };

  xdg.configFile."kak-lsp/kak-lsp.toml".text =
    let orig = builtins.readFile (pkgs.kak-lsp.src + "/kak-lsp.toml");
    in builtins.replaceStrings [ "rls" ] [ "rust-analyzer" ] orig;

  home.file = let
    dirPath = firefox + "/lib/mozilla/native-messaging-hosts/";
    fileNames = builtins.attrNames (builtins.readDir dirPath);
    files = map (n: {
      path = dirPath + n;
      name = n;
    }) fileNames;
  in builtins.foldl' (a:
    { name, path }:
    a // {
      ".mozilla/native-messaging-hosts/${name}".source = path;
    }) { } files;

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
  home.stateVersion = "20.09";
}
