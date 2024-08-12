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
    # forceSSL = true;
    locations."/" = {
      proxyPass = "${config.services.grafana.settings.server.root_url}";
      proxyWebsockets = true;
    };
  };

  sops.secrets.grafana-initial-password.owner = "grafana";
}
