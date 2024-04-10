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

    services.navidrome = {
      listen.port = 41457;
      settings = {
        BaseUrl = "https://music.home.ashwalker.net";
        RecentlyAddedByModTime = true;
        CoverArtPriority = "embedded, cover.*, folder.*, front.*, external";
        EnableUserEditing = false;
        TranscodingCacheSize = "1GiB";
        FFmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
        EnableSharing = true;
      };
      dir.library = "/elysium/media/audio/library";
    };

    services.nginx.virtualHosts."music.home.ashwalker.net" = {
      enableACME = true;
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      locations."/" = {
        proxyPass = "http://${navi.listen.address}:${toString navi.listen.port}";
      };
    };
  };
  meta = {};
}
