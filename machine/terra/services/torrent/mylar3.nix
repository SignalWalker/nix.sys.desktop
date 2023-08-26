{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  mylar3 = config.services.mylar3;
  ini = pkgs.formats.ini {};
in {
  options = with lib; {
    services.mylar3 = {
      enable = mkEnableOption "mylar3";
      package = mkOption {
        type = types.package;
        default = pkgs.mylar3;
      };
      user = mkOption {
        type = types.str;
        default = "mylar3";
      };
      group = mkOption {
        type = types.str;
        default = "mylar3";
      };
      port = mkOption {
        type = types.port;
        default = 43057;
      };
      dataDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/${mylar3.user}";
      };
      configDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/etc/${mylar3.user}";
      };
      cacheDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/cache/${mylar3.user}";
      };
      logDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/log/${mylar3.user}";
      };
      hostName = mkOption {
        type = types.str;
      };
      settings = mkOption {
        type = ini.type;
        default = {};
      };
      settingsFile = mkOption {
        type = types.path;
        readOnly = true;
        default = ini.generate "mylar3.ini" mylar3.settings;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf mylar3.enable {
    users.users.${mylar3.user} = {
      isSystemUser = true;
      home = mylar3.dataDir;
      group = mylar3.group;
    };
    users.groups.${mylar3.group} = {};

    # environment.etc."${mylar3.user}/data" = {
    #   source = "${mylar3.package.src}/data";
    #   user = mylar3.user;
    #   group = mylar3.group;
    # };

    systemd.services."mylar3" = {
      after = ["network.target" "syslog.target"];
      wantedBy = ["multi-user.target"];
      path = let pypkgs = pkgs.python311Packages; in [pkgs.unrar pypkgs.pip];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        Type = "simple";
        User = mylar3.user;
        Group = mylar3.group;

        WorkingDirectory = mylar3.dataDir;

        StateDirectory = mylar3.user;
        StateDirectoryMode = "0750";

        ConfigurationDirectory = mylar3.user;
        ConfigurationDirectoryMode = "0750";

        CacheDirectory = mylar3.user;
        CacheDirectoryMode = "0750";

        LogsDirectory = mylar3.user;
        LogsDirectoryMode = "0750";

        ExecStart = "${mylar3.package}/bin/mylar3 -v -p ${toString mylar3.port} --datadir ${mylar3.dataDir}${
          if mylar3.settings != {}
          then "--config ${mylar3.settingsFile}"
          else ""
        }";
      };
    };

    # system.aclMap = {
    #   "/elysium/media/text/graphic" = {
    #     entries = [
    #       {
    #         type = "user";
    #         entity = mylar3.user;
    #         read = true;
    #         write = true;
    #         execute = true;
    #       }
    #     ];
    #   };
    #   "/elysium/media/text/torrent" = {
    #     entries = [
    #       {
    #         type = "user";
    #         entity = mylar3.user;
    #         read = true;
    #         write = false;
    #         execute = true;
    #       }
    #     ];
    #   };
    # };

    services.nginx.virtualHosts."${mylar3.hostName}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString mylar3.port}";
      };
    };
  };
  meta = {};
}
