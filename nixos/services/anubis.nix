{
  config,
  pkgs,
  lib,
  options,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  anubis = config.services.anubis;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    services.anubis = {
      defaultOptions = {
        settings = {
          OG_PASSTHROUGH = true;
          WEBMASTER_EMAIL = "ash@ashwalker.net";
          SERVE_ROBOTS_TXT = true;
        };
      };
    };
  };
  meta = { };
}
