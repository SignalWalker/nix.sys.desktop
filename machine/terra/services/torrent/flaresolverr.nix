{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  flare = config.services.flaresolverr;
in {
  options = with lib; {
    services.flaresolverr = {
      enable = mkEnableOption "flaresolverr";
      chromium = mkOption {
        type = types.package;
        default = pkgs.ungoogled-chromium;
      };
      src = mkOption {
        type = types.path;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.python311Packages.buildPythonApplication {
          name = "flaresolverr";
          src = flare.src;
        };
      };
      user = mkOption {
        type = types.str;
        default = "flaresolverr";
      };
      group = mkOption {
        type = types.str;
        default = "flaresolverr";
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf flare.enable {
    users.users.${flare.user} = {
      isSystemUser = true;
      group = flare.group;
    };
    users.groups.${flare.group} = {};
    systemd.services."flaresolverr" = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      path = [flare.chromium];
      environment = {
        LOG_LEVEL = "info";
        CAPTCHA_SOLVER = "none";
      };
      serviceConfig = {
        SyslogIdentifier = "flaresolverr";
        Restart = "always";
        RestartSec = 5;
        Type = "simple";
        User = flare.user;
        Group = flare.group;
        WorkingDirectory = "/var/lib/${flare.user}";
        StateDirectory = flare.user;
        ExecStart = "${flare.package}/bin/flaresolverr";
      };
    };
  };
  meta = {};
}
