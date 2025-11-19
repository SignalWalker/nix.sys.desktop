{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (config.services.desktopManager.manager == "sway") {
    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraPackages = [
        pkgs.swaylock
        # swaylock-effects
        pkgs.swayidle
      ];
    };

    programs.uwsm.waylandCompositors.sway = {
      prettyName = "Sway";
      comment = "Sway compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/sway";
    };

    xdg.portal = {
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "wlr"
            "gtk"
          ];
        };
      };
    };
  };
  meta = { };
}
