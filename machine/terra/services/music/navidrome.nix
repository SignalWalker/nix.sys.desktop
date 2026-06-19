{
  config,
  pkgs,
  lib,
  ...
}:
let
  navi = config.services.navidrome;
  toml = pkgs.formats.toml { };
in
{
  options =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        mkPackageOption
        ;
    in
    {
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
        package = mkPackageOption pkgs "navidrome" { };
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
          library = mkOption {
            type = types.str;
          };
        };
        settings = mkOption {
          type = toml.type;
          default = { };
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
            default = "127.0.0.1";
          };
          port = mkOption {
            type = types.port;
            default = 4533;
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
  disabledModules = [ "services/audio/navidrome.nix" ];

  config = lib.mkIf navi.enable (
    let
      jukeboxEnabled = navi.settings ? Jukebox && navi.settings.Jukebox.Enabled or false;
    in
    {
      warnings = [ "using custom navidrome module" ];
      users.users.${navi.user} = {
        group = navi.group;
        isSystemUser = true;
        # FIX :: check whether this is necessary for jukebox
        extraGroups = lib.optional jukeboxEnabled "audio";
        # this is so the wireplumber service activates without a login session
        linger = jukeboxEnabled;
      };
      users.groups.${navi.group} = { };

      systemd.user.services.wireplumber.wantedBy = lib.mkIf jukeboxEnabled [ "default.target" ];

      services.navidrome.settings = {
        MusicFolder = navi.dir.library;
        DataFolder = "${navi.dir.state}/data";
        CacheFolder = navi.dir.cache;
        Address = navi.listen.address;
        Port = navi.listen.port;
      };

      # systemd.sockets."navidrome" = {
      #   after = ["mutli-user.target"];
      #   wantedBy = ["socket.target"];
      #   listenStreams = [navi.listen.address];
      #   socketConfig = {
      #     Accept = false;
      #     SocketUser = navi.listen.user;
      #     SocketGroup = navi.listen.group;
      #     SocketMode = "0660";
      #   };
      # };

      environment.etc."navidrome.toml" = {
        user = navi.user;
        group = navi.group;
        source = navi.settingsFile;
        target = "${navi.user}/navidrome.toml";
      };

      systemd.services."navidrome" = {
        description = "Navidrome Music Server and Streamer compatible with Subsonic/Airsonic";
        after = [
          "remote-fs.target"
          "network.target"
        ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.opus-tools
          pkgs.ffmpeg
        ]
        ++ (lib.optional jukeboxEnabled pkgs.mpv);
        environment = {
          # "ND_ENABLETRANSCODINGCONFIG" = "true";
        };
        restartTriggers = [ navi.settingsFile ];
        serviceConfig = {
          User = navi.user;
          Group = navi.group;

          Type = "simple";
          ExecStart = "${navi.package}/bin/navidrome --configfile ${navi.dir.cfg}/navidrome.toml";
          KillMode = "process";
          Restart = "on-failure";

          WorkingDirectory = navi.dir.state;
          RuntimeDirectory = navi.user;
          StateDirectory = navi.user;
          CacheDirectory = navi.user;
          LogsDirectory = navi.user;
          ConfigurationDirectory = navi.user;
          RuntimeDirectoryMode = "0755";
          StateDirectoryMode = "0750";
          CacheDirectoryMode = "0750";
          LogsDirectoryMode = "0750";
          ConfigurationDirectoryMode = "0750";
          ReadWritePaths = [
            navi.dir.runtime
            navi.dir.state
            navi.dir.cache
            navi.dir.logs
            navi.dir.cfg
          ];
          BindReadOnlyPaths = [
            "${
              config.environment.etc."ssl/certs/ca-certificates.crt".source
            }:/etc/ssl/certs/ca-certificates.crt"
            navi.dir.library
            builtins.storeDir
          ];

          DevicePolicy = "closed";
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectControlGroups = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallFilter = [
            "~@clock"
            "@debug"
            "@module"
            "@mount"
            "@obsolete"
            "@reboot"
            "@setuid"
            "@swap"
          ];
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };
    }
  );
  meta = { };
}

