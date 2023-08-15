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
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraEnv = {
          # "MANGOHUD" = true;
          # "OBS_VKCAPTURE" = true;
        };
        extraPkgs = pkgs:
          with pkgs; [
            # mangohud
            gamescope
          ];
      };
    };
  };
  meta = {};
}
