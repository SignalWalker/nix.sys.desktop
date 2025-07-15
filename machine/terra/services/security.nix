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
  options = with lib; {};
  disabledModules = [];
  imports = lib.listFilePaths ./security;
  config = {
    services.crowdsec = {
      enable = false; # there aren't any bouncers packaged yet.......
      settings = {
        api.server.trusted_ips = [
          "172.24.86.0/24" # wg-signal
        ];
      };
      extraGroups = [
        "nginx"
      ];
    };
  };
  meta = {};
}