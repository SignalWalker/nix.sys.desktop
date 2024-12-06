{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  flood = config.services.flood-ui;
in {
  options = with lib; {
    services.flood-ui = {
      enable = mkEnableOption "flood bittorrent web ui";
      package = mkPackageOption pkgs "flood" {};
      user = mkOption {
        type = types.str;
        default = "flood";
      };
      group = mkOption {
        type = types.str;
        default = flood.user;
      };
      configDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/etc/${flood.user}";
      };
      dataDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/${flood.user}";
      };
      port = mkOption {
        type = types.port;
        default = 43257;
      };
      hostName = mkOption {
        type = types.str;
      };
      baseUri = mkOption {
        type = types.str;
        default = "/";
      };
      serveAssets = mkEnableOption "";
      auth = mkOption {
        type = types.enum ["default" "none"];
        default = "default";
      };
      qbittorrent = {
        enable = mkEnableOption "qbittorrent integration";
        url = mkOption {
          type = types.str;
        };
        user = mkOption {
          type = types.str;
        };
        passwordFile = mkOption {
          type = types.str;
        };
      };
      deluge = {
        enable = mkEnableOption "deluge integration";
        hostName = mkOption {
          type = types.str;
        };
        port = mkOption {
          type = types.port;
        };
        user = mkOption {
          type = types.str;
        };
        passwordFile = mkOption {
          type = types.str;
        };
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf flood.enable {
    users.users.${flood.user} = {
      isSystemUser = true;
      group = flood.group;
      home = flood.dataDir;
    };
    users.groups.${flood.group} = {};

    services.nginx.virtualHosts."${flood.hostName}" = let
      baseUri =
        if flood.baseUri == "/"
        then ""
        else flood.baseUri;
    in {
      locations."${baseUri}/api" = {
        proxyPass = "http://127.0.0.1:${toString flood.port}";
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
      locations."${baseUri}/" = {
        alias = "${flood.package}/lib/node_modules/flood/dist/assets/";
        tryFiles = "$uri /flood/index.html";
      };
      extraConfig = lib.mkIf (flood.baseUri != "/") ''
        rewrite ^${flood.baseUri}$ ${flood.baseUri}/ permanent;
      '';
    };

    systemd.services.flood = {
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target"];
      description = "Flood Bittorrent UI";
      wantedBy = ["multi-user.target"];
      path = [flood.package];
      serviceConfig = {
        EnvironmentFile =
          (std.optionals flood.qbittorrent.enable [
            flood.qbittorrent.passwordFile
          ])
          ++ (std.optionals flood.deluge.enable [
            flood.deluge.passwordFile
          ]);
        ConfigurationDirectory = flood.user;
        StateDirectory = flood.user;
        Type = "simple";
        KillMode = "process";
        ExecStart = let
          opts =
            {
              rundir = flood.dataDir;
              host = "127.0.0.1";
              port = flood.port;
              baseuri = flood.baseUri;
              assets =
                if flood.serveAssets
                then "true"
                else "false";
              auth = flood.auth;
            }
            // (std.optionalAttrs flood.qbittorrent.enable {
              qburl = flood.qbittorrent.url;
              qbuser = flood.qbittorrent.user;
              qbpass = "$FLOOD_QBITTORRENT_PASSWORD";
            })
            // (std.optionalAttrs flood.deluge.enable {
              dehost = flood.deluge.host;
              deport = flood.deluge.port;
              deuser = flood.deluge.user;
              depass = "$FLOOD_DELUGE_PASSWORD";
            });
          optsArgs = map (key: "--${key}=${toString opts.${key}}") (attrNames opts);
        in
          "${flood.package}/bin/flood " + (std.concatStringsSep " " optsArgs);
        User = flood.user;
        Group = flood.group;
        Restart = "on-failure";
        RestartSec = 3;

        # security
        CapabilityBoundingSet = [""];
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "@pkey" "~@privileged"];
      };
    };
  };
  meta = {};
}
