{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    environment.systemPackages = [ pkgs.river ];
    services.displayManager.sessionPackages = [ pkgs.river ];
    xdg.portal.config.river.default = [ "wlr" "gtk" ];
  };
  meta = { };
}
