{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  jackett = config.services.jackett;
  sonarr = config.services.sonarr;
in {
  options = with lib; {
    services.sonarr = {
      port = mkOption {
        type = types.port;
        readOnly = true;
        default = 8989;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    services.sonarr = {
      enable = jackett.enable;
      openFirewall = false;
    };
    # NOTE :: make sure to edit ${sonarr.dataDir}/config.xml as per https://wiki.servarr.com/sonarr/postgres-setup#schema-creation
    # NOTE :: and to set the password & db ownership
    services.postgresql = lib.mkIf sonarr.enable {
      ensureDatabases = [
        "sonarr-main"
        "sonarr-log"
      ];
      ensureUsers = [
        {
          name = "sonarr";
        }
      ];
    };
  };
  meta = {};
}
