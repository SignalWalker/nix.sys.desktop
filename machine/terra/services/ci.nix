{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  hydra = config.services.hydra;
  baseDomain = "home.ashwalker.net";
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = lib.mkMerge [
    {
      services.woodpecker-server = {
        enable = false;
        environment = {
          WOODPECKER_HOST = "https://woodpecker.${baseDomain}";
          WOODPECKER_OPEN = "false";
          WOODPECKER_ADMIN = "ash";
        };
      };
    }
    {
      services.hydra = {
        enable = false;
        listenHost = "127.0.0.1";
        notificationSender = "hydra@${baseDomain}";
        port = 49232;
        useSubstitutes = true;
        hydraURL = "hydra.${baseDomain}";
        buildMachinesFiles = [];
      };

      services.nginx.virtualHosts = lib.mkIf hydra.enable {
        ${hydra.hydraURL} = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString hydra.port}";
          };
        };
      };
    }
  ];
  meta = {};
}
