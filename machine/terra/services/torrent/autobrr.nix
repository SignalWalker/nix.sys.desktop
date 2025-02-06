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
      port = mkOption {
        type = types.port;
        default = 7474;
      };
      hostName = mkOption {
        type = types.str;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf autobrr.enable (lib.mkMerge [
    {
      services.nginx.virtualHosts."${autobrr.hostName}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString autobrr.port}";
        };
      };
    }
  ]);
  meta = {};
}
