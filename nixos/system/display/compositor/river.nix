{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (config.services.desktopManager.manager == "river") {
    programs.river = {
      enable = true;
      xwayland.enable = true;
      extraPackages = [
        pkgs.swaylock
        pkgs.swayidle
      ];
    };
  };
  meta = { };
}
