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
  imports = lib.signal.fs.path.listFilePaths ./artemis;
  config = {
    networking.networkmanager = {
      enable = true;
    };
    signal.network.wireguard.networks."wg-signal".addresses = ["fd24:fad3:8246::2" "172.24.86.2"];
  };
  meta = {};
}
