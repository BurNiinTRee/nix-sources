{...}: {
  sound.enable = true;

  services.pipewire = {
    systemWide = true;
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # Currently we need to manually link the source to the output using pw-link
  # No idea why target.object doesn't work
  environment.etc."pipewire/pipewire.conf.d/99-rtp-source.conf".text = ''
    context.modules = [
      {   name = libpipewire-module-rtp-source
          args = {
              source.ip = "0.0.0.0"
              source.port = 46000
              sess.ignore-ssrc = true
              # sess.latency.msec = 100
              stream.props = {
                media.class = "Audio/Source"
                node.name = "rtp-source"
                node.autoconnect = true
                audio.channels = 4
                audio.position = [ AUX0 AUX1  AUX2 AUX3 ]
                # target.object = "alsa_output.usb-BEHRINGER_UMC1820_A4F5966D-00.multichannel-output"
              }
          }
      }
    ]
  '';

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        use_mpris = false;
      };
    };
  };
  systemd.services.spotifyd.serviceConfig = {
    SupplementaryGroups = ["pipewire"];
  };
}
