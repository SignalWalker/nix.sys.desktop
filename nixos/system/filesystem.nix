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
    # essentially a file manager interface to udisks
    services.gvfs = {
      enable = true;
    };
    services.tumbler = {
      # dbus thumbnail service
      enable = true;
    };
    environment.systemPackages = [
      # .odf
      pkgs.libgsf
      # .webp
      pkgs.webp-pixbuf-loader
      # pdf
      pkgs.poppler
      # epub / mobi
      pkgs.gnome-epub-thumbnailer
      # various 3D formats
      pkgs.f3d
      # video
      pkgs.ffmpegthumbnailer
      # .raw
      pkgs.nufraw-thumbnailer
    ];
  };
  meta = {};
}
