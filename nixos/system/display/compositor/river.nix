{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  river = config.programs.river;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = lib.mkIf (config.services.desktopManager.manager == "river") {
    programs.river = {
      enable = true;
      xwayland.enable = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
      ];
    };
  };
  meta = {};
}
