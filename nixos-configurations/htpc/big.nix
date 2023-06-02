{
  config,
  pkgs,
  lib,
  flakeInputs,
  ...
}: {
  services.xserver.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    socketActivation = true;
    alsa = {
      enable = true;
    };
    pulse.enable = true;
  };

  services.xserver.libinput.enable = true;
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableScreensaver = false;
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      intel-media-driver
    ];
  };
  users.users.user.packages = with pkgs; [
    firefox
    intel-gpu-tools
    libva-utils
    pulseaudio
  ];

  programs.kdeconnect.enable = true;

  hardware.steam-hardware.enable = true;

  systemd.user.services.spotifyd = {
    wantedBy = ["default.target"];
    bindsTo = ["dbus.service"];
    after = ["network-online.target" "pipewire.socket"];
    description = "spotifyd, a Spotify playing daemon";
    environment.SHELL = "/bin/sh";
    serviceConfig = {
      ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path ${
        (pkgs.formats.toml {}).generate "spotifyd.conf"
        {
          global = {
            device_name = "Nelly/Lars";
            bitrate = 320;
            device_type = "speaker";
            max_cache_size = 0;
            zeroconf_port = 1234;
            backend = "alsa";
            device = "pipewire";
            dbus_type = "session";
            use_mpris = true;
          };
        }
      }";
      Restart = "always";
      RestartSec = 12;
    };
  };

  networking.firewall.allowedTCPPorts = [1234 4713 64000];
  networking.firewall.allowedUDPPorts = [1234 4713 64000];

  environment.systemPackages = with pkgs; [
    sc-controller
    qpwgraph
  ];
}
