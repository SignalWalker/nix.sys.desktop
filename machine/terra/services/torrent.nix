{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  qbit = config.services.qbittorrent;
  jackett = config.services.jackett;
  radarr = config.services.radarr;
  sonarr = config.services.sonarr;
  lidarr = config.services.lidarr;
  readarr = config.services.readarr;
  prowlarr = config.services.prowlarr;
  jseer = config.services.jellyseerr;
in {
  options = with lib; {
    services.jackett = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 9117;
      };
    };
    services.radarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 7878;
      };
    };
    services.sonarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 8989;
      };
    };
    services.lidarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 8686;
      };
    };
    services.readarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 8787;
      };
    };
    services.prowlarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 9696;
      };
    };
  };
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./torrent;
  config = {
    services.qbittorrent = {
      enable = true;
      webui = {
        hostName = "torrent.terra.ashwalker.net";
      };
    };

    services.jackett = {
      enable = qbit.enable;
      openFirewall = false;
    };

    services.radarr = {
      enable = jackett.enable;
      openFirewall = false;
    };

    services.sonarr = {
      enable = jackett.enable;
      openFirewall = false;
    };

    services.lidarr = {
      enable = jackett.enable;
      openFirewall = false;
    };

    services.readarr = {
      enable = jackett.enable;
      openFirewall = false;
    };

    services.prowlarr = {
      enable = jackett.enable;
      openFirewall = false;
    };

    services.jellyseerr = {
      enable = false; # config.services.jellyfin.enable && qbit.enable;
      openFirewall = false;
    };

    services.flaresolverr = {
      enable = false;
    };

    services.cross-seed = {
      enable = true;
      # configFilePath = "/home/ash/.config/cross-seed/config.js";
    };

    services.autobrr = {
      enable = false;
      hostName = "autobrr.${qbit.webui.hostName}";
    };

    terra.network.tunnel.users = [
      qbit.user
      # jackett.user
      # radarr.user
    ];

    services.nginx.virtualHosts = lib.mkMerge [
      (lib.mkIf jackett.enable {
        "search.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          locations."/" = {
            extraConfig = ''
              proxy_pass         http://127.0.0.1:${toString jackett.port}/;
              proxy_http_version 1.1;

              proxy_set_header   Host               127.0.0.1:${toString jackett.port};
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-For    $remote_addr;
            '';
          };
        };
      })
      (lib.mkIf radarr.enable {
        "radarr.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          locations."/" = {
            extraConfig = ''
              proxy_pass         http://127.0.0.1:${toString radarr.port}/;
              proxy_http_version 1.1;

              proxy_set_header   Host               127.0.0.1:${toString radarr.port};
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-For    $remote_addr;
            '';
          };
        };
      })
      (lib.mkIf sonarr.enable {
        "sonarr.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          locations."/" = {
            extraConfig = ''
              proxy_pass         http://127.0.0.1:${toString sonarr.port}/;
              proxy_http_version 1.1;

              proxy_set_header   Host               127.0.0.1:${toString sonarr.port};
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-For    $remote_addr;
            '';
          };
        };
      })
      (lib.mkIf lidarr.enable {
        "lidarr.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          locations."/" = {
            extraConfig = ''
              proxy_pass         http://127.0.0.1:${toString lidarr.port}/;
              proxy_http_version 1.1;

              proxy_set_header   Host               127.0.0.1:${toString lidarr.port};
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-For    $remote_addr;
            '';
          };
        };
      })
      (lib.mkIf readarr.enable {
        "readarr.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          locations."/" = {
            extraConfig = ''
              proxy_pass         http://127.0.0.1:${toString readarr.port}/;
              proxy_http_version 1.1;

              proxy_set_header   Host               127.0.0.1:${toString readarr.port};
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-For    $remote_addr;
            '';
          };
        };
      })
      (lib.mkIf prowlarr.enable {
        "prowlarr.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          locations."/" = {
            extraConfig = ''
              proxy_pass         http://127.0.0.1:${toString prowlarr.port}/;
              proxy_http_version 1.1;

              proxy_set_header   Host               127.0.0.1:${toString prowlarr.port};
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-For    $remote_addr;
            '';
          };
        };
      })
      (lib.mkIf jseer.enable {
        "seer.${qbit.webui.hostName}" = {
          # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
          extraConfig = ''
            proxy_set_header Referer $http_referer;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Real-Port $remote_port;
            proxy_set_header X-Forwarded-Host $host:$remote_port;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-Port $remote_port;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Ssl on;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString jseer.port}";
          };
        };
      })
    ];
  };
  meta = {};
}
