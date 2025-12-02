{
  config,
  pkgs,
  lib,
  ...
}:
let
  navi = config.services.navidrome;
  domain = "music.home.ashwalker.net";
  # anubis = config.services.anubis;
in
{
  imports = lib.listFilePaths ./music;
  config = {
    services.navidrome = {
      enable = true;
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
      enable = false; # FIX :: disbled because it was messing with phone client (also why did i even enable it in the first place)
      settings = {
        TARGET = "http://${navi.listen.address}:${toString navi.listen.port}";
        SOCKET_MODE = "0777"; # FIX :: does this really need to be 0777
        COOKIE_DOMAIN = domain;
      };
    };

    services.nginx.virtualHosts."music.home.ashwalker.net" = {
      useACMEHost = "home.ashwalker.net";
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      locations."/" = {
        proxyPass = "http://${navi.listen.address}:${toString navi.listen.port}";
        # proxyPass = "http://unix:${anubis.instances."navidrome".settings.BIND}";
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