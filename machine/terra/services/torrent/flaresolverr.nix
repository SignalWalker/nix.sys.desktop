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
      chromium = mkOption {
        type = types.package;
        default = pkgs.ungoogled-chromium;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.flaresolverr;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf flare.enable {
    services.flaresolverr = {
      openFirewall = false;
      port = 46909;
    };
    systemd.services."flaresolverr" = {
      path = [flare.chromium];
      environment = {
        LOG_LEVEL = "info";
        CAPTCHA_SOLVER = "none";
      };
    };
    services.nginx.virtualHosts."solverr.${config.services.qbittorrent.webui.hostName}" = {
      enableACME = false;
      forceSSL = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString flare.port}";
      };
    };
  };
  meta = {};
}
