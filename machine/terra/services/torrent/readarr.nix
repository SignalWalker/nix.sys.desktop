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
    # NOTE :: make sure to edit ${readarr.dataDir}/config.xml as per https://wiki.servarr.com/readarr/postgres-setup#schema-creation
    services.postgresql = {
      ensureDatabases = [
        "readarr-main"
        "readarr-log"
        "readarr-cache"
      ];
      ensureUsers = [
        {
          name = "readarr";
        }
      ];
    };
  };
  meta = {};
}
