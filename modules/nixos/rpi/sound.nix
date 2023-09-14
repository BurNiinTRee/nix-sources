{
  pkgs,
  lib,
  ...
}: let
  rtp-source-connect = pkgs.writeScriptBin "rtp-source-connect" ''
    #!${pkgs.nushell}/bin/nu
    $env.PATH = '${lib.makeBinPath [pkgs.pipewire]}'
    sleep 5sec
    let sourcePorts = pw-link -Io | lines | parse -r '^\s*(?<id>\d+)\s+(?<name>\S+):(?<port>\S+)$' | where name == "rtp-source" | sort-by -n port
    let sinkPorts = pw-link -Ii | lines | parse -r '^\s*(?<id>\d+)\s+(?<name>\S+):(?<port>\S+)$' | where name =~ "UMC1820" | sort-by -n port | first 4
    $sourcePorts | zip $sinkPorts | each {|e| print $'Connecting ($e.0.name):($e.0.port) ($e.0.id) -> ($e.1.name):($e.1.port) ($e.1.id)'; pw-link $e.0.id $e.1.id}
  '';
in {
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
    context.exec = [
      {
        path = "${rtp-source-connect}/bin/rtp-source-connect"
      }
    ]
  '';

  environment.systemPackages = [
    pkgs.nushell
    rtp-source-connect
  ];

  security.rtkit.enable = true;

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
