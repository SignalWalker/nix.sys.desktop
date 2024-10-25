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
    home.packages = [pkgs.godot_4];
    desktop.windows = [
      {
        criteria = {
          "instance" = "Godot_Engine";
          "title" = ".*DEBUG.*";
        };
        floating = true;
      }
    ];
  };
  meta = {};
}
