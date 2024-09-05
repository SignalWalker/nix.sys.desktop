{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  prom = config.services.prometheus;
  exporters = prom.exporters;
  grafana = config.services.grafana;
  ntopng = config.services.ntopng;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = lib.mkMerge [
    {
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 40673;
            domain = "monitor.terra.ashwalker.net";
          };
        };
      };
      services.prometheus = {
        enable = true;
        exporters = {
          node = {
            enable = true;
            port = 9100;
            enabledCollectors = [
              "logind"
              "systemd"
            ];
            disabledCollectors = [
              "textfile"
            ];
            openFirewall = false;
          };
          systemd = {
            enable = true;
          };
        };
        scrapeConfigs = [
          {
            job_name = "terra";
            static_configs = [
              {
                targets = [
                  "localhost:${toString exporters.node.port}"
                  "localhost:${toString exporters.systemd.port}"
                ];
              }
            ];
          }
        ];
      };
      services.nginx.virtualHosts."${grafana.settings.server.domain}" = {
        locations."/" = {
          proxyPass = "http://${toString grafana.settings.server.http_addr}:${toString grafana.settings.server.http_port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
      services.ntopng = {
        enable = false; # FIX :: workaround for build failure 2024-08-26
        httpPort = 46504;
        interfaces = [
          "enp4s0"
          "wg-airvpn"
          "wg-signal"
          "wg-torrent"
        ];
      };
    }
    (lib.mkIf ntopng.enable {
      # IPFIX
      networking.firewall.allowedUDPPorts = [4739];
      services.nginx.virtualHosts."bandwidth.monitor.terra.ashwalker.net" = {
        locations."/" = {
          proxyPass = "http://localhost:${toString ntopng.httpPort}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    })
  ];
  meta = {};
}
