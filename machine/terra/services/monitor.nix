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
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
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
  };
  meta = {};
}
