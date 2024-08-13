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

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listener_port = 3100;
      ingester = {
        lifecycler = {
          address = "0.0.0.0";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 1048576;
        chunk_retention_period = "30s";
        max_transfer_retries = 0;
      };
      schema_config.configs = [
        {
          from = "2024-08-13";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          cache_ttl = "24h";
          shared_store = "filesystem";
        };
        filesystem.directory = "/var/lib/loki/chunks";
      };
      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
      chunk_store_config.max_look_back_period = "0s";
      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };
    };
  };
}
