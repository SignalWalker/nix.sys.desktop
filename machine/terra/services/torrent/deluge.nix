{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  deluge = config.services.deluge;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.deluge = let
      deluge = config.services.deluge;
    in {
      enable = true;
      # authFile = null; # todo
      declarative = false; # todo
      openFirewall = false;
      config = {
        download_location = "${deluge.dataDir}/downloads";
        share_ratio_limit = "2.0";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [6881 6889];
      };
      web = {
        enable = false; # todo
        openFirewall = false;
        port = 8112;
      };
    };

    terra.network.tunnel.users = [
      deluge.user
    ];
  };
  meta = {};
}
