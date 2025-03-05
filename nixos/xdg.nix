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
    xdg = {
      terminal-exec = {
        enable = true;
        settings = {
          default = [
            "kitty.desktop"
          ];
        };
      };
      sounds.enable = true;
      # portal - see nixos/system/display
    };
  };
  meta = {};
}
