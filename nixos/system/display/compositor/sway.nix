{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    {
      programs.sway = {
        enable = true;
        xwayland = {
          enable = true;
        };
        wrapperFeatures = {
          base = false; # handled by uwsm (? i think?)
          gtk = true;
        };
        extraPackages = [
          pkgs.swaylock
          # swaylock-effects
          pkgs.swayidle
        ];
      };

      programs.uwsm = {
        enable = true;
        waylandCompositors.sway = {
          prettyName = "Sway";
          comment = "Sway compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/sway";
        };
      };

    }
    (lib.mkIf (config.services.desktopManager.manager == "sway") {
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
    })
  ];
  meta = { };
}
