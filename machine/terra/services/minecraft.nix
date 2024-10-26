{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  driftingLeague = config.services.minecraft.driftingLeague;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.minecraft.driftingLeague = {
      enable = false;
      java.memory = {
        initial = "1024M";
        max = "8912M";
      };
      packwiz.hostName = "minecraft.home.ashwalker.net";
      openFirewall = true;
      prism.name = "DriftingLeague";
    };
    services.nginx.virtualHosts = lib.mkIf driftingLeague.enable {
      ${driftingLeague.packwiz.hostName} = {
        listenAddresses = config.services.nginx.publicListenAddresses;
        enableACME = true;
        addSSL = true;
      };
    };
  };
  meta = {};
}
