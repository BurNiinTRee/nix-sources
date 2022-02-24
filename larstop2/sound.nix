{ config, pkgs, lib, ... }:
{
  # Realtime stuff
  security.rtkit.enable = true;

  musnix = {
    enable = true;
    kernel = {
      # optimize = true;
      # realtime = true;
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    socketActivation = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    config.jack = {
      "jack.properties" = {
        "jack.short-name" = true;
        # "node.latency" = "64/48000";
      };
      "jack.rules" = [{
        matches = [
          {
            "application.process.binary" = "pianoteq";
          }
          {
            "application.process.binary" = "reaper";
          }
        ];
        actions.update-props."node.latency" = "64/48000";
      }];
    };

    config.client-rt = {
      "stream.properties" = {
        "node.latency" = "64/48000";
      };
    };

    wireplumber.enable = true;
    media-session.enable = !config.services.pipewire.wireplumber.enable;

    pulse.enable = true;
    config.pipewire-pulse = {
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -11;
            "rt.prio" = 88;
            "rt.time.soft" = 2000000;
            "rt.time.hard" = 2000000;
          };
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-metadata"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "server.address" = [ "unix:native" ];
            "vm.overrides" = {
              "pulse.min.quantum" = "1024/48000";
            };
          };
        }
      ];
    };
    config.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
        "log.level" = 2;
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 8192;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };

      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -11;
            "rt.prio" = 88;
            "rt.time.soft" = 2000000;
            "rt.time.hard" = 2000000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-profiler"; }
        { name = "libpipewire-module-metadata"; }
        { name = "libpipewire-module-spa-device-factory"; }
        { name = "libpipewire-module-spa-node-factory"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-client-device"; }
        {
          name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }
        {
          name = "libpipewire-module-access";
          args = { };
        }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }

        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "UMC_Mic";
            "node.description" = "Behringer Input 8";
            "playback.props" = {
              "media.class" = "Audio/Source";
              "audio.position" = [ "MONO" ];
            };
            "capture.props" = {
              "audio.position" = [ "AUX7" ];
              "stream.dont-mix" = true;
              "node.target" = "alsa_input.usb-BEHRINGER_UMC1820_A4F5966D-00.pro-input-0";
              "node.passive" = true;
            };
          };
        }
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.name" = "UMC_Headphones";
            "node.description" = "UMC Headphones";
            "capture.props" = {
              "media.class" = "Audio/Sink";
              "audio.position" = [ "FL" "FR" ];
            };
            "playback.props" = {
              "audio.position" = [ "AUX0" "AUX1" ];
              "stream.dont-mix" = true;
              "node.target" = "alsa_output.usb-BEHRINGER_UMC1820_A4F5966D-00.pro-output-0";
              "node.passive" = true;
            };
          };
        }
      ];
    };
  };
}
