{
  config,
  pkgs,
  lib,
  flakeInputs,
  ...
}: {
  # Realtime stuff
  security.rtkit.enable = true;

  environment.etc."pipewire/pipewire.conf.d/rtkit.conf".text = ''
    context.modules = [
      { name = "libpipewire-module-rt"
        args = {
        }
      }
    ]
  '';
  environment.etc."pipewire/jack.conf.d/rtkit.conf".text = ''
    context.modules = [
      { name = "libpipewire-module-rt"
        args = {
        }
      }
    ]
  '';

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "95";
    }
    {
      domain = "@audio";
      item = "nice";
      type = "-";
      value = "-19";
    }
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "4194304";
    }
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    socketActivation = true;
    alsa = {
      enable = true;
      # support32Bit = true;
    };
    jack.enable = true;
    wireplumber.enable = true;

    pulse.enable = true;
  };
  networking.firewall.allowedTCPPorts = [9875 9876];
  networking.firewall.allowedUDPPorts = [9875 9876];
}
