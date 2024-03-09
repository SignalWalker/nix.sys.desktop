{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  sway = config.programs.sway;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
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
  };
  meta = {};
}
