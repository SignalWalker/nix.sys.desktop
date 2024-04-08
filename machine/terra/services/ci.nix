{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  domain = "hydra.home.ashwalker.net";
  hydra = config.services.hydra;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.hydra = {
      enable = true;
      listenHost = "localhost";
      notificationSender = "hydra@home.ashwalker.net";
      port = 49232;
      useSubstitutes = true;
      hydraURL = "https://${domain}";
      buildMachinesFiles = [];
    };

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString hydra.port}";
      };
    };
  };
  meta = {};
}
