{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  navi = config.services.navidrome;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./music;
  config = {
    services.navidrome = {
      enable = true;
    };

    services.navidrome.settings = {
      BaseUrl = "https://music.home.ashwalker.net";
    };

    services.nginx.virtualHosts."music.home.ashwalker.net" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${navi.listen.address}";
      };
    };
  };
  meta = {};
}
