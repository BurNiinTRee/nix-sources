{
  config,
  pkgs,
  lib,
  flakeInputs,
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

    pulse.enable = true;
  };
  networking.firewall.allowedTCPPorts = [9875 9876];
  networking.firewall.allowedUDPPorts = [9875 9876];
}
