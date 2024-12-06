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
    services.deluge = {
      enable = false;
      # authFile = null; # todo
      declarative = false; # todo
      openFirewall = false;
      config = {
        download_location = "/elysium/torrent/downloads";
        daemon_port = 58846;
        listen_ports = [18698];
      };
      web = {
        enable = false; # todo
        openFirewall = false;
        port = 8112;
      };
    };

    terra.network.tunnel.users = lib.mkIf deluge.enable [
      deluge.user
    ];

    networking.firewall = lib.mkIf deluge.enable {
      allowedUDPPorts = deluge.config.listen_ports;
      allowedTCPPorts = deluge.config.listen_ports;
    };
  };
  meta = {};
}
