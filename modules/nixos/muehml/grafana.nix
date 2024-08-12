{config, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server.domain = "grafana.${config.networking.fqdn}";
      server.port = 2342;
      security.admin_password = "$__file{${config.sops.secrets.grafana-initial-password.path}}";
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
  };
}
