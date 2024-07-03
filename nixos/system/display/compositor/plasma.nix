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
  config = lib.mkIf (config.services.desktopManager.manager == "plasma6") {
    services.xserver.enable = true;
    services.desktopManager.plasma6 = {
      enable = true;
    };
    services.displayManager.sddm = {
      enable = true;
      wayland = {
        enable = true;
      };
    };
  };
  meta = {};
}
