{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    # services.transmission = {
    #   enable = true;
    #   settings = {
    #   };
    #   openPeerPorts = true;
    #   openRPCPort = true;
    # };
    services.deluge = let
      deluge = config.services.deluge;
    in {
      enable = false; # todo
      # authFile = null; # todo
      declarative = false; # todo
      openFirewall = true;
      config = {
        download_location = "${deluge.dataDir}/downloads";
        share_ratio_limit = "2.0";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [6881 6889];
      };
      web = {
        enable = false; # todo
        openFirewall = true;
        port = 8112;
      };
    };
  };
  meta = {};
}
