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
    networking.firewall.allowedTCPPorts = [
      # syncthing
      22000
    ];
    networking.firewall.allowedUDPPorts = [
      # syncthing
      22000
      # syncthing discovery broadcasts
      21027
    ];
  };
  meta = {};
}
