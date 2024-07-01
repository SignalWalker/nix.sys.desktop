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
  };
  meta = {};
}
