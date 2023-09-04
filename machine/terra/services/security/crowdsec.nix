{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  crowdsec = config.services.crowdsec;
in {
  options = with lib; {
    services.crowdsec = {
      enable = mkEnableOption "crowdsec";
      package = mkOption {
        type = types.package;
        default = pkgs.crowdsec;
      };
      user = mkOption {
        type = types.str;
        default = "crowdsec";
      };
      group = mkOption {
        type = types.str;
        default = "crowdsec";
      };
      dir = {
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/lib/${crowdsec.user}";
        };
        configuration = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/${crowdsec.user}";
        };
      };
      settingsFile = mkOption {
        type = types.str;
        default = "${crowdsec.dir.configuration}/config.yaml";
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf crowdsec.enable {
    users.users.${crowdsec.user} = {
      isSystemUser = true;
      createHome = true;
      home = crowdsec.dir.state;
      inherit (crowdsec) group;
    };
    environment.systemPackages = [
      crowdsec.package
    ];
    users.groups.${crowdsec.group} = {};
    systemd.services."crowdsec" = {
      after = ["syslog.target" "network.target" "remote-fs.target" "nss-lookup.target"];
      wantedBy = ["multi-user.target"];
      path = [crowdsec.package];
      environment = {
        LC_ALL = "C";
        LANG = "C";
      };
      serviceConfig = {
        StateDirectory = crowdsec.user;
        ConfigurationDirectory = crowdsec.user;
        Type = "notify";
        ExecStartPre = "${crowdsec.package}/bin/crowdsec -c ${crowdsec.settingsFile} -t -error";
        ExecStart = "${crowdsec.package}/bin/crowdsec -c ${crowdsec.settingsFile}";
        ExecReload = "/usr/bin/env kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = 60;
      };
    };
  };
  meta = {};
}
