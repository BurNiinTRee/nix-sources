inputs: { config, pkgs, ... }:
let
  firefox = with pkgs;
    wrapFirefox firefox-bin-unwrapped {
      forceWayland = true;
      extraNativeMessagingHosts = [ browserpass gnomeExtensions.gsconnect ];
      applicationName = "firefox";
      pname = "firefox";
      desktopName = "Firefox";
    };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  systemd.user.startServices = true;

  home.packages = with pkgs; [
    blanket
    cargo-edit
    carla
    clang-tools
    deluge
    dua
    easyeffects
    exa
    exercism
    fd
    ffmpeg
    file
    fira-code
    firefox
    gamescope
    gcc
    gnome3.gnome-tweaks
    gnomeExtensions.gsconnect
    gnomeExtensions.appindicator
    gnumake
    graphviz
    helvum
    helix
    htop
    inputs.rnix-flake.packages.x86_64-linux.rnix-lsp
    inputs.deploy-rs.defaultPackage.x86_64-linux #.packages.x86_64-linux.nixops
    inputs.reaper.defaultPackage.x86_64-linux
    intel-gpu-tools
    iftop
    jitsi-meet-electron
    julia
    killall
    kodi-wayland
    krita-beta
    matlab
    mullvad-vpn
    pavucontrol
    pciutils
    pijul
    pulseaudio
    qjackctl
    ripgrep
    rust-analyzer
    rustfmt
    simple-http-server
    spotify
    teams
    texlab
    thunderbird-wayland
    tokei
    transmission-gtk
    usbutils
    virtmanager
    vlc
    wev
    wl-clipboard
    xournalpp
    zoom-us
  ] ++
  # LV2 Plugins
  [
    calf
    helm
    inputs.pianoteq.defaultPackage.x86_64-linux
    inputs.organteq.defaultPackage.x86_64-linux
    rnnoise-plugin
    CHOWTapeModel
    ams-lv2
    artyFX
    avldrums-lv2
    bchoppr
    bjumblr
    boops
    bschaffl
    bsequencer
    bshapr
    bslizr
    distrho
    drumgizmo
    eq10q
    # faustPhysicalModeling
    # faustStk
    fmsynth
    fomp
    fverb
    gxmatcheq-lv2
    gxplugins-lv2
    infamousPlugins
    kapitonov-plugins-pack
    magnetophonDSP.CharacterCompressor
    magnetophonDSP.CompBus
    # magnetophonDSP.ConstantDetuneChorus
    magnetophonDSP.LazyLimiter
    magnetophonDSP.MBdistortion
    magnetophonDSP.RhythmDelay
    magnetophonDSP.VoiceOfFaust
    # magnetophonDSP.faustCompressors
    magnetophonDSP.pluginUtils
    magnetophonDSP.shelfMultiBand
    mda_lv2
    metersLv2
    mod-distortion
    molot-lite
    mooSpace
    ninjas2
    noise-repellent
    plujain-ramp
    rkrlv2
    sfizz
    sorcer
    surge
    swh_lv2
    talentedhack
    tunefish
    vocproc
    x42-avldrums
    x42-gmsynth
    zam-plugins
    zyn-fusion
  ];

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        exec nu
      '';
      shellAliases = {
        cat = "bat";
        iftop = "sudo iftop -B -m 100M";
        ls = "exa";
      };
    };

    bat = {
      enable = true;
      config.theme = "Solarized (light)";
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    fzf = {
      enable = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = {
        pull = { ff = "only"; };
        init = { defaultBranch = "main"; };
      };
      userEmail = "larsmuehmel@web.de";
      userName = "Lars Mühmel";
    };

    gpg.enable = true;

    kakoune = {
      enable = true;
      plugins =
        [ pkgs.kak-cargo pkgs.kak-surround pkgs.kak-digraphs ];
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
            name = "WinSetOption";
            option = "filetype=(rust|julia|nix|latex)";
            commands = "lsp-enable-window";
          }
          {
            name = "WinSetOption";
            option = "filetype=julia";
            commands = "digraphs-enable-on <a-d> <a-s>";
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
            docstring = "Surround selection";
            effect = ": surround<ret>";
            key = "s";
            mode = "user";
          }
          {
            docstring = "Select next placeholder";
            effect = "<a-;>: lsp-snippets-select-next-placeholders<ret>";
            key = "<a-tab>";
            mode = "insert";
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

    nushell = {
      enable = true;
      settings = {
        prompt = "starship prompt";
        startup = [
          # "alias cat = bat"
          "alias iftop = sudo iftop -B -m 100M"
          "zoxide init nushell --hook prompt | save /tmp/zoxide.nu"
          "source /tmp/zoxide.nu"
          "mkdir ~/.cache/starship"
          "starship init nu | save ~/.cache/starship/init.nu"
          "source ~/.cache/starship/init.nu"
        ];
      };
    };

    obs-studio = {
      enable = true;
    };

    password-store.enable = true;

    starship = {
      enable = true;
      settings = {
        status.disabled = false;
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    nextcloud-client.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };


  xdg.configFile."kak/digraphs/digraphs.dat".source = pkgs.kak-digraphs + "/share/kak/autoload/plugins/digraphs.dat";

  # xdg.configFile."kak-lsp/kak-lsp.toml".text =
  #   let orig = builtins.readFile (pkgs.kak-lsp.src + "/kak-lsp.toml");
  #   in
  #   (builtins.replaceStrings [ "if command -v rustup >/dev/null; then $(rustup which rls); else rls; fi" ] [ ("env CARGO=${pkgs.cargo}/bin/cargo RUSTC=${pkgs.rustc}/bin/rustc RUSTFMT=${pkgs.rustfmt}/bin/rustfmt ${pkgs.rust-analyzer}/bin/rust-analyzer") ] orig);

  xdg.configFile."pijul/config.toml".text = pkgs.lib.generators.toINI
    { }
    {
      author = {
        name = ''"BurNiinTRee"'';
        full_name = ''"Lars Mühmel"'';
        email = ''"larsmuehmel@web.de"'';
      };
    };


  home.sessionVariables = {
    EDITOR = "kak";
    LV2_PATH = pkgs.lib.strings.makeSearchPath "" [
      "/etc/profiles/per-user/lars/lib/lv2"
    ];
    LADSPA_PATH = pkgs.lib.strings.makeSearchPath "" [
      "/etc/profiles/per-user/lars/lib"
    ];
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
