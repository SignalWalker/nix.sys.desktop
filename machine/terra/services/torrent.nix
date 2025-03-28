{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  qbit = config.services.qbittorrent;
  deluge = config.services.deluge;
  jackett = config.services.jackett;
  radarr = config.services.radarr;
  sonarr = config.services.sonarr;
  lidarr = config.services.lidarr;
  readarr = config.services.readarr;
  prowlarr = config.services.prowlarr;
  jseer = config.services.jellyseerr;
  udpt = config.services.udpt;

  secrets = config.age.secrets;
in {
  options = with lib; {
    services.jackett = {
      # port = mkOption {
      #   type = types.port;
      #   readOnly = true;
      #   default = 9117;
      # };
    };
    services.radarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 7878;
      };
    };
    services.lidarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 8686;
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
    age.secrets = {
      floodSecrets.file = ./torrent/secrets/floodSecrets.age;
    };

    services.qbittorrent = {
      enable = !config.services.deluge.enable;
      webui = {
        hostName = "torrent.terra.ashwalker.net";
      };
    };

    systemd.services."update-dynamic-ip" = {
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.curl];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          cookiePath = "/elysium/torrent/mam.cookies";
        in "${pkgs.curl}/bin/curl -c ${cookiePath} -b ${cookiePath} https://t.myanonamouse.net/json/dynamicSeedbox.php";
        User = qbit.user;
        Group = qbit.group;
      };
    };

    # TODO :: set up bitmagnet

    services.flood-ui = {
      enable = true;
      hostName = qbit.webui.hostName;
      baseUri = "/flood";
      auth = "none";
      qbittorrent = {
        enable = qbit.enable;
        url = "http://${qbit.webui.hostName}";
        user = "ash";
        passwordFile = secrets.floodSecrets.path;
      };
      deluge = {
        enable = deluge.enable;
        passwordFile = secrets.floodSecrets.path;
      };
    };

    services.jackett = {
      enable = false; # qbit.enable;
      openFirewall = false;
    };

    services.radarr = {
      enable = true;
      openFirewall = false;
    };

    services.lidarr = {
      enable = false;
      openFirewall = false;
    };

    services.prowlarr = {
      enable = true;
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
      enable = false;
      # configFilePath = "/home/ash/.config/cross-seed/config.js";
    };

    services.mylar3 = {
      enable = false;
      hostName = "mylar3.${qbit.webui.hostName}";
      settings = {};
    };

    services.kaizoku = {
      enable = false;
      hostName = "kaizoku.${qbit.webui.hostName}";
    };

    # system.aclMap = let
    #   mapUsers = users:
    #     map (user: {
    #       type = "user";
    #       entity = user;
    #       read = true;
    #       write = true;
    #       execute = true;
    #     })
    #     users;
    #   withUsers = users: {
    #     recursive = true;
    #     append = true;
    #     entries = mapUsers users;
    #   };
    # in {
    #   "/elysium/media/video/film" = withUsers [radarr.user qbit.user];
    #   "/elysium/media/video/tv" = withUsers [sonarr.user qbit.user];
    #   "/elysium/media/video/torrent" = withUsers [sonarr.user radarr.user qbit.user];
    # };

    terra.network.tunnel.users = [
      qbit.user
      # jackett.user
      # radarr.user
    ];

    services.udpt = {
      enable = false;
      settings = {
        mode = "dynamic";
        udp = {
          bind_address = "0.0.0.0:${toString udpt.port}";
          announce_interval = 60 * 15; # this is in seconds
        };
        # http = {
        #   bind_address = "127.0.0.1:${toString (udpt.port + 1)}";
        # };
      };
    };

    services.nginx.virtualHosts = let
      # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];
      # listen = [
      #   {
      #   }
      # ];
    in
      lib.mkMerge [
        (lib.mkIf jackett.enable {
          "search.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString jackett.port}";
          };
        })
        (lib.mkIf radarr.enable {
          "radarr.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString radarr.port}";
          };
        })
        (lib.mkIf sonarr.enable {
          "sonarr.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString sonarr.port}";
          };
        })
        (lib.mkIf lidarr.enable {
          "lidarr.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString lidarr.port}";
          };
        })
        (lib.mkIf readarr.enable {
          "readarr.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString readarr.port}";
          };
        })
        (lib.mkIf prowlarr.enable {
          "prowlarr.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString prowlarr.port}";
          };
        })
        (lib.mkIf jseer.enable {
          "seer.${qbit.webui.hostName}" = {
            # inherit listenAddresses;
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
