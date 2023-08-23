{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  autobrr = config.services.autobrr;
  toml = pkgs.formats.toml {};
in {
  options = with lib; {
    services.autobrr = {
      enable = mkEnableOption "autobrr";
      package = mkOption {
        type = types.package;
        default = pkgs.autobrr;
      };
      user = mkOption {
        type = types.str;
        default = "autobrr";
      };
      group = mkOption {
        type = types.str;
        default = "autobrr";
      };
      port = mkOption {
        type = types.port;
        default = 7474;
      };
      dataDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/${autobrr.user}";
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
        default = toml.generate "autobrr.toml" autobrr.settings;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf autobrr.enable (lib.mkMerge [
    {
      users.users.${autobrr.user} = {
        isSystemUser = true;
        home = "/var/lib/${autobrr.user}";
        group = autobrr.group;
      };
      users.groups.${autobrr.group} = {};

      systemd.services."autobrr" = {
        after = ["network.target" "syslog.target"];
        wantedBy = ["multi-user.target"];
        path = [];
        serviceConfig = {
          Restart = "always";
          RestartSec = 5;
          Type = "simple";
          User = autobrr.user;
          Group = autobrr.group;
          WorkingDirectory = autobrr.dataDir;
          StateDirectory = autobrr.user;
          ConfigurationDirectory = autobrr.user;
          StateDirectoryMode = "0750";
          ExecStart = "${autobrr.package}/bin/autobrr --config=${autobrr.dataDir}/.config/autobrr/";
        };
      };

      services.nginx.virtualHosts."${autobrr.hostName}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString autobrr.port}";
        };
      };
    }
  ]);
  meta = {};
}
