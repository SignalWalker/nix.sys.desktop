{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  mylar3 = config.services.mylar3;
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
      hostName = mkOption {
        type = types.str;
      };
      settings = mkOption {
        type = toml.type;
        default = {};
      };
      settingsFile = mkOption {
        type = types.path;
        readOnly = true;
        default = toml.generate "mylar3.toml" mylar3.settings;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf mylar3.enable {
    users.users.${mylar3.user} = {
      isSystemUser = true;
      home = "/var/lib/${mylar3.user}";
      group = mylar3.group;
    };
    users.groups.${mylar3.group} = {};

    systemd.services."mylar3" = {
      after = ["network.target" "syslog.target"];
      wantedBy = ["multi-user.target"];
      path = [];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        Type = "simple";
        User = mylar3.user;
        Group = mylar3.group;
        WorkingDirectory = mylar3.dataDir;
        StateDirectory = mylar3.user;
        ConfigurationDirectory = mylar3.user;
        StateDirectoryMode = "0750";
        ExecStart = "${mylar3.package}/bin/mylar3 -v";
      };
    };

    services.nginx.virtualHosts."${mylar3.hostName}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString mylar3.port}";
      };
    };
  };
  meta = {};
}
