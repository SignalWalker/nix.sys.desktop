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
  imports = lib.signal.fs.path.listFilePaths ./compositor;
  config = {
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      WLR_RENDERER = "vulkan";
      WINIT_UNIX_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland;xcb";
      MOZ_ENABLE_WAYLAND = toString 1;
    };

    programs.uwsm = {
      enable = true;
    };
  };
  meta = {};
}
