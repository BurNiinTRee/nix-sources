{ config, pkgs, lib, ... }:
{
  age.secrets.pleroma-secrets = {
    owner = "pleroma";
    group = "pleroma";
    file = ../secrets/pleroma-secrets.age;
  };
  nixpkgs.overlays = [ (import ../overlays/pleroma.nix) ];
  services.pleroma = {
    enable = true;
    package = pkgs.akkoma;
    secretConfigFile = config.age.secrets.pleroma-secrets.path;
    configs = [
      ''
        # Pleroma instance configuration
        
        # NOTE: This file should not be committed to a repo or otherwise made public
        # without removing sensitive information.
        
        import Config
        
        config :pleroma, Pleroma.Web.Endpoint,
           url: [host: "social.muehml.eu", scheme: "https", port: 443],
           http: [ip: {127, 0, 0, 1}, port: 4000]

        config :pleroma, Pleroma.Web.WebFinger, domain: "muehml.eu"
        
        config :pleroma, :instance,
          name: "social.muehml.eu",
          email: "social@muehml.eu",
          notify_email: "social@muehml.eu",
          limit: 5000,
          registrations_open: false
        
        config :pleroma, :media_proxy,
          enabled: false,
          redirect_on_failure: true
          #base_url: "https://cache.pleroma.social"
        
        config :pleroma, Pleroma.Repo,
          adapter: Ecto.Adapters.Postgres,
          username: "akkoma",
          database: "akkoma",
          hostname: "localhost"
        
        # Configure web push notifications
        config :web_push_encryption, :vapid_details,
          subject: "mailto:social@muehml.eu"
        
        config :pleroma, :database, rum_enabled: false
        config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
        config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"
        
        # Enable Strict-Transport-Security once SSL is working:
        # config :pleroma, :http_security,
        #   sts: true
        
        # Configure S3 support if desired.
        # The public S3 endpoint (base_url) is different depending on region and provider,
        # consult your S3 provider's documentation for details on what to use.
        #
        # config :pleroma, Pleroma.Upload,
        #  uploader: Pleroma.Uploaders.S3,
        #  base_url: "https://s3.amazonaws.com"
        #
        # config :pleroma, Pleroma.Uploaders.S3,
        #   bucket: "some-bucket",
        #   bucket_namespace: "my-namespace",
        #   truncated_namespace: nil,
        #   streaming_enabled: true
        #
        # Configure S3 credentials:
        # config :ex_aws, :s3,
        #   access_key_id: "xxxxxxxxxxxxx",
        #   secret_access_key: "yyyyyyyyyyyy",
        #   region: "us-east-1",
        #   scheme: "https://"
        #
        # For using third-party S3 clones like wasabi, also do:
        # config :ex_aws, :s3,
        #   host: "s3.wasabisys.com"
        
        config :pleroma, Pleroma.Emails.Mailer,
          enabled: true,
          adapter: Swoosh.Adapters.SMTP,
          relay: "mail.muehml.eu",
          port: 587,
          tls: :always
        
        config :pleroma, configurable_from_database: false
      ''
    ];
  };

  systemd.services.pleroma.environment."DEBUG" = "1";

  services.nginx.virtualHosts = {
    "muehml.eu".locations."/.well-known/host-meta".return = "301 https://social.muehml.eu$request_uri";
    "social.muehml.eu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
      };
    };
  };
}