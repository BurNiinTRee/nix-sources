{ config, pkgs, ... }:

let
  wellKnownServer = pkgs.writeTextFile {
    name = "server";
    text = ''{ "m.server": "matrix.muehml.eu:443" }'';
    destination = "/.well-known/matrix/server";
  };
  wellKnownClient = pkgs.writeTextFile {
    name = "client";
    text = ''
      {
          "m.homeserver": {
              "base_url": "https://matrix.muehml.eu"
          },
          "im.vector.element.jitsi": {
              "preferredDomain": "jitsi.muehml.eu"
          }
      }'';
    destination = "/.well-known/matrix/client";
  };

in {
  networking.firewall = {
    allowedUDPPorts = [ 5349 5350 ];
    allowedTCPPorts = [ 80 443 3478 3479 3306 ];
  };

  services.prosody.xmppComplianceSuite = false;

  services.nginx = {
    enable = true;
    virtualHosts = {
      "matrix.muehml.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = { proxyPass = "http://localhost:8008"; };
      };

      "element.muehml.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/".root = (pkgs.element-web.override {
          conf = {
            default_server_config = {
              "m.homeserver" = {
                base_url = "https://matrix.muehml.eu";
                server_name = "muehml.eu";
              };
            };

            jitsi.preferredDomain = "jitsi.muehml.eu";
          };
        });
      };

      ${config.services.jitsi-meet.hostName} = {
        enableACME = true;
        forceSSL = true;
      };

      "muehml.eu" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/.well-known/" = {
            root = pkgs.symlinkJoin {
              name = "wellKnown";
              paths = [ wellKnownClient wellKnownServer ];
            };
            extraConfig = ''
              add_header 'Access-Control-Allow-Origin' '*';
            '';
          };
          "/".return = "301 https://jitsi.muehml.eu$request_uri";
        };

      };

    };

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };

  services.matrix-synapse = {
    enable = true;
    server_name = "muehml.eu";
    enable_metrics = true;
    enable_registration = true;

    database_type = "psycopg2";
    database_args.password = "synapse";

    app_service_config_files = [ "/etc/telegram-registration.yaml" ];

    listeners = [{
      port = 8008;
      tls = false;
      resources = [{
        compress = true;
        names = [ "client" "webclient" "federation" ];
      }];
    }];

    turn_uris = [
      "turn:turn.muehml.eu:3478?transport=udp"
      "turn:turn.muehml.eu:3478?transport=tcp"
    ];
    # turn_shared_secret = config.services.coturn.static-auth-secret;
  };

  services.postgresql = {
    enable = true;

    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };

  services.jitsi-meet = {
    enable = true;
    hostName = "jitsi.muehml.eu";
  };
  services.jitsi-videobridge = {
    enable = true;
    openFirewall = true;
  };

  services.coturn = {
    enable = true;
    use-auth-secret = true;
    # static-auth-secret = builtins.readFile ./coturn-secret;
    realm = "turn.muehml.eu";
    no-tcp-relay = true;
    no-tls = true;
    no-dtls = true;
    extraConfig = ''
      user-quota=12
      total-quota=1200
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255

      allowed-peer-ip=49.12.64.193
    '';
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = "/etc/mautrix-env";
    settings = {
      homeserver = {
        domain = "muehml.eu";
        address = "http://localhost:8008";
      };
      bridge.permissions = {
        "@lars:muehml.eu" = "admin";
        "muehml.eu" = "full";
      };
    };

  };

  security.acme = {
    acceptTerms = true;
    email = "larsmuehmel@web.de";
  };

}

