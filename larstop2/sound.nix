{
  config,
  pkgs,
  lib,
  ...
}: {
  # Realtime stuff
  security.rtkit.enable = true;

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
    media-session.enable = !config.services.pipewire.wireplumber.enable;

    pulse.enable = true;
  };
}
