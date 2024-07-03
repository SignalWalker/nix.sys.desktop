{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  hypr = config.programs.hyprland;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = lib.mkIf (config.services.desktopManager.manager == "hyprland") {
    programs.hyprland = {
      enable = true;
      systemd.setPath.enable = true;
      xwayland.enable = true;
    };
  };
  meta = {};
}
