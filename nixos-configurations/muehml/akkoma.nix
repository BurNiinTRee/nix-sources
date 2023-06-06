{
  config,
  pkgs,
  lib,
  ...
}: let
  format = pkgs.formats.elixirConf {};
in {
  age.secrets.pleroma-secrets = {
    owner = "akkoma";
    group = "akkoma";
    file = ../../secrets/pleroma-secrets.age;
  };
  services.akkoma = {
    enable = true;
    config.":pleroma" = {
      ":instance" = {
        name = "Muehml.eu";
        description = "Private Akkoma Server For The Fediverse";
        email = "social@muehml.eu";
        notify_email = "social@muehml.eu";
        registrations_open = false;
        invitates_enables = true;
      };
      "Pleroma.Web.Endpoint" = {
        http = {
          ip = "127.0.0.1";
          port = 4000;
        };
        url = {
          host = "social.muehml.eu";
          scheme = "https";
        };
      };
      "Pleroma.Web.WebFinger" = {
        domain = "muehml.eu";
      };
      "Pleroma.Emails.Mailer" = {
        adapter = format.lib.mkRaw "Swoosh.Adapters.SMTP";
        enabled = true;
        relay = "127.0.0.1";
        username = "lars@muehml.eu";
        password._secret = config.age.secrets.pleroma-secrets.path;
      };
    };
    nginx = {
      enableACME = true;
      forceSSL = true;
    };
  };

  services.nginx.virtualHosts = {
    "muehml.eu".locations."/.well-known/host-meta".return = "301 https://social.muehml.eu$request_uri";
  };
}
