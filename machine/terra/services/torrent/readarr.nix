{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  jackett = config.services.jackett;
  readarr = config.services.readarr;
in {
  options = with lib; {
    services.readarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 8787;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    services.readarr = {
      enable = jackett.enable;
      openFirewall = false;
    };
  };
  meta = {};
}
