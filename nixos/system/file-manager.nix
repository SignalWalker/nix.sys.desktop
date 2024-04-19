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
    # programs.thunar = {
    #   enable = true;
    #   plugins = with pkgs.xfce; [
    #     thunar-archive-plugin
    #     thunar-volman
    #     thunar-media-tags-plugin
    #   ];
    # };

    # mount, trash, etc.
    services.gvfs = {
      enable = true;
    };

    # dbus thumbnail service
    services.tumbler = {
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
