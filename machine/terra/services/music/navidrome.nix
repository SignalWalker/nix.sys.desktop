{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  navi = config.services.navidrome;
  toml = pkgs.formats.toml {};
  mkTomlFile = name: src: (lib.mkOption {
    type = lib.types.path;
    readOnly = true;
    default = toml.generate name src;
  });
in {
  options = with lib; {
    services.navidrome = {
      enable = mkEnableOption "navidrome";
      user = mkOption {
        type = types.str;
        default = "navidrome";
      };
      group = mkOption {
        type = types.str;
        default = "navidrome";
      };
      package = mkPackageOption pkgs "navidrome" {};
      dir = {
        runtime = mkOption {
          type = types.str;
          readOnly = true;
          default = "/run/${navi.user}";
        };
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/lib/${navi.user}";
        };
        cache = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/cache/${navi.user}";
        };
        logs = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/log/${navi.user}";
        };
        cfg = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/${navi.user}";
        };
      };
      settings = mkOption {
        type = toml.type;
        default = {};
      };
      settingsFile = mkOption {
        type = types.path;
        readOnly = true;
        default = toml.generate "navidrome.toml" navi.settings;
      };
      listen = {
        address = mkOption {
          type = types.str;
          readOnly = true;
          default = "${navi.dir.runtime}/listen.socket";
        };
        user = mkOption {
          type = types.str;
          default = navi.user;
        };
        group = mkOption {
          type = types.str;
          default = navi.group;
        };
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf navi.enable {
    users.users.${navi.user} = {
      group = navi.group;
      isSystemUser = true;
    };
    users.groups.${navi.group} = {};

    services.navidrome.settings = {
      DataFolder = "${navi.dir.state}/data";
      CacheFolder = navi.dir.cache;
      Address = "unix:${navi.listen.address}";
    };

    systemd.sockets."navidrome" = {
      after = ["mutli-user.target"];
      wantedBy = ["socket.target"];
      listenStreams = [navi.listen.address];
      socketConfig = {
        Accept = false;
        SocketUser = navi.listen.user;
        SocketGroup = navi.listen.group;
        SocketMode = "0660";
      };
    };

    systemd.services."navidrome" = {
      description = "Navidrome Music Server and Streamer compatible with Subsonic/Airsonic";
      after = ["remote-fs.target" "network.target"];
      serviceConfig = {
        User = navi.user;
        Group = navi.group;

        Type = "simple";
        ExecStart = "${navi.package}/bin/navidrome --configfile ${navi.settingsFile}";
        KillMode = "process";
        Restart = "on-failure";

        WorkingDirectory = navi.dir.state;
        RuntimeDirectory = navi.user;
        StateDirectory = navi.user;
        CacheDirectory = navi.user;
        LogsDirectory = navi.user;
        ConfigurationDirectory = navi.user;

        DevicePolicy = "closed";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateUser = true;
        ProtectControlGroup = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallFilter = ["~@clock" "@debug" "@module" "@mount" "@obsolete" "@reboot" "@setuid" "@swap"];
        ReadWritePaths = [navi.dir.state];
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
  meta = {};
}
