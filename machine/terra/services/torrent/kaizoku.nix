{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  kaizoku = config.services.kaizoku;
in {
  options = with lib; {
    services.kaizoku = {
      enable = mkEnableOption "kaizoku";
      package = mkOption {
        type = types.package;
        default = pkgs.kaizoku;
      };
      user = mkOption {
        type = types.str;
        default = "kaizoku";
      };
      group = mkOption {
        type = types.str;
        default = "kaizoku";
      };
      port = mkOption {
        type = types.port;
        default = 43057;
      };
      dataDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/${kaizoku.user}";
      };
      configDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/etc/${kaizoku.user}";
      };
      cacheDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/cache/${kaizoku.user}";
      };
      logDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/log/${kaizoku.user}";
      };
      hostName = mkOption {
        type = types.str;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf kaizoku.enable {
    users.users.${kaizoku.user} = {
      isSystemUser = true;
      home = kaizoku.dataDir;
      group = kaizoku.group;
    };
    users.groups.${kaizoku.group} = {};

    # environment.etc."${kaizoku.user}/data" = {
    #   source = "${kaizoku.package.src}/data";
    #   user = kaizoku.user;
    #   group = kaizoku.group;
    # };

    systemd.services."kaizoku" = {
      after = ["network.target" "syslog.target"];
      wantedBy = ["multi-user.target"];
      path = let pypkgs = pkgs.python311Packages; in [pkgs.unrar pypkgs.pip];
      environment = {
        DATABASE_URL = "postgresql://";
      };
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        Type = "simple";
        User = kaizoku.user;
        Group = kaizoku.group;

        WorkingDirectory = kaizoku.dataDir;

        StateDirectory = kaizoku.user;
        StateDirectoryMode = "0750";

        ConfigurationDirectory = kaizoku.user;
        ConfigurationDirectoryMode = "0750";

        CacheDirectory = kaizoku.user;
        CacheDirectoryMode = "0750";

        LogsDirectory = kaizoku.user;
        LogsDirectoryMode = "0750";

        ExecStart = "echo buh";
      };
    };

    services.redis.servers."kaizoku" = {
      enable = kaizoku.enable;
      user = kaizoku.user;
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["kaizoku"];
      ensureUsers = [
        {
          name = kaizoku.user;
          ensurePermissions."DATABASE kaizoku" = "ALL PRIVILEGES";
        }
      ];
    };

    # virtualisation.oci-containers.containers."kaizoku" = {
    #   user = "${kaizoku.user}:${kaizoku.group}";
    #   ports = ["127.0.0.1::${toString kaizoku.port}"];
    # };

    services.nginx.virtualHosts."${kaizoku.hostName}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString kaizoku.port}";
      };
    };
  };
  meta = {};
}
