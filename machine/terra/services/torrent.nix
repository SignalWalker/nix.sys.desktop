{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  qbit = config.services.qbittorrent;
  magnetico = config.services.magnetico;
in {
  options = with lib; {
  };
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./torrent;
  config = {
    services.qbittorrent = {
      enable = true;
      webui = {
        hostName = "torrent.home.ashwalker.net";
      };
    };

    services.jackett = {
      enable = true;
      # port = 9117;
    };

    services.magnetico = {
      enable = false; # qbit.enable;
      web = {
        credentialsFile = "/var/lib/magnetico/credentials";
        port = 43257;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf magnetico.enable [magnetico.crawler.port];

    services.nginx.virtualHosts = lib.mkIf magnetico.enable {
      "dht.${qbit.webui.hostName}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          extraConfig = ''
            proxy_pass         http://127.0.0.1:${toString magnetic.web.port}/;
            proxy_http_version 1.1;

            proxy_set_header   Host               127.0.0.1:${toString magnetico.web.port};
            proxy_set_header   X-Forwarded-Host   $http_host;
            proxy_set_header   X-Forwarded-For    $remote_addr;
          '';
        };
      };
    };
  };
  meta = {};
}
