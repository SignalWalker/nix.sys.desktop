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
    wayland.windowManager.sway.config = {
      output = {
        # laptop screen
        "BOE 0x0BCA Unknown" = {
          max_render_time = "2";
        };
      };
    };
  };
  meta = {};
}
