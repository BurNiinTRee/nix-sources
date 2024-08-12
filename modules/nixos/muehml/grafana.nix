{config, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server.domain = "grafana.${config.networking.fqdn}";
      server.port = 2342;
      security.admin_password = "$__file{${config.sops.secrets.grafana-initial-password.path}}";
      smtp = {
        enabled = true;
        from_address = "grafana@muehml.eu";
        skip_verify = true;
      };
    };
  };
  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  sops.secrets.grafana-initial-password.owner = "grafana";

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
      port = 9002;
    };
    scrapeConfigs = [
      {
        job_name = "muehml";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };
}
