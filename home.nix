{ config, pkgs, ... }:
let
  firefox = with pkgs;
    (wrapFirefox firefox-bin-unwrapped {
      forceWayland = true;
      extraNativeMessagingHosts = [ browserpass gnomeExtensions.gsconnect ];
      browserName = "firefox";
      pname = "firefox-bin";
      desktopName = "Firefox";
    });

  LD_LIBRARY_PATH = "${pkgs.pipewire.lib}/lib/pipewire-0.3/jack";

  wrapDesktopInBash = pkg: oldExecLine: execLine: desktopName:
    pkgs.stdenv.mkDerivation {
      inherit (pkg) name version meta;
      phases = [ "buildPhase" ];
      buildPhase = ''
        cp -r ${pkg} $out
        substituteInPlace $out/share/applications/${desktopName} --replace '${oldExecLine}' '${execLine}'
      '';
    };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  systemd.user.startServices = true;
  systemd.user.sessionVariables = { inherit LD_LIBRARY_PATH; };

  home.packages = with pkgs; [
    (wrapDesktopInBash ardour "Exec=ardour6" ''Exec=bash -l -c "ardour6"''
      "ardour6.desktop")
    #(wrapDesktopInBash firefox "Exec=firefox %U" ''Exec=bash -l -c "firefox %U"'' "firefox.desktop")
    firefox
    (wrapDesktopInBash qjackctl "Exec=qjackctl" ''Exec=bash -l -c "qjackctl"''
      "qjackctl.desktop")
    cargo-edit
    du-dust
    fd
    file
    fira-code
    ffmpeg
    flatpak-builder
    gcc
    gnome3.gnome-tweaks
    gnomeExtensions.gsconnect
    gnomeExtensions.draw-on-your-screen
    helm
    htop
    iftop
    killall
    niv
    nixfmt
    nixops
    pciutils
    pw-pulse
    ripgrep
    rustup
    steam
    thunderbird-bin
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
        inherit LD_LIBRARY_PATH;
        LV2_PATH = "~/.nix-profile/lib/lv2";
      };
      shellAliases = {
        cat = "bat";
        iftop = "sudo iftop -B -m 10M";
      };
    };

    kakoune = {
      enable = true;
      config = {
        colorScheme = "gruvbox";
        numberLines = {
          enable = true;
          highlightCursor = true;
          relative = true;
        };
        ui.statusLine = "top";
        hooks = [{
          commands = "lsp-enable-window";
          name = "WinSetOption";
          option = "filetype=rust";
        }];
      };
      extraConfig = ''
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
