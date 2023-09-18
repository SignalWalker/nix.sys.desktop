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
    services.minecraft.driftingLeague = {
      enable = true;
      java.memory = {
        initial = "1024M";
        max = "8912M";
      };
      packwiz.hostName = "minecraft.home.ashwalker.net";
      openFirewall = true;
      prism.name = "DriftingLeague";
    };
  };
  meta = {};
}
