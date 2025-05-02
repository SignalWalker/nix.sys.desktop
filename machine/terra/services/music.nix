{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  navi = config.services.navidrome;
  domain = "music.home.ashwalker.net";
  anubis = config.services.anubis;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = lib.signal.fs.path.listFilePaths ./music;
  config = {
    services.navidrome = {
      enable = true;
    };

    services.navidrome = {
      listen.port = 41457;
      settings = {
        BaseUrl = "https://${domain}";
        RecentlyAddedByModTime = true;
        CoverArtPriority = "embedded, cover.*, folder.*, front.*, external";
        EnableUserEditing = false;
        TranscodingCacheSize = "1GiB";
        FFmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
        EnableSharing = true;
      };
      dir.library = "/elysium/media/audio/library";
    };

    services.anubis.instances."navidrome" = {
      enable = true;
      settings = {
        TARGET = "http://${navi.listen.address}:${toString navi.listen.port}";
        SOCKET_MODE = "0777"; # FIX :: does this really need to be 0777
        COOKIE_DOMAIN = domain;
      };
    };

    services.nginx.virtualHosts."music.home.ashwalker.net" = {
      enableACME = true;
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      locations."/" = {
        proxyPass = "http://unix:${anubis.instances."navidrome".settings.BIND}";
      };
    };

    services.glance.monitorSites = [
      {
        title = "Navidrome";
        url = "https://music.home.ashwalker.net";
      }
    ];
  };
  meta = { };
}
