{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = lib.mkIf (config.services.desktopManager.manager == "sway") {
    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraPackages = with pkgs; [
        swaylock
        # swaylock-effects
        swayidle
      ];
    };

    programs.uwsm.waylandCompositors.sway = {
      prettyName = "Sway";
      comment = "Sway compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/sway";
    };
  };
  meta = {};
}
