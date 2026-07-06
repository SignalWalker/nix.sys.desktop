{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) foldl' attrNames;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.desktopManager.manager = mkOption {
        type = types.enum [
          "plasma6"
          "sway"
          "river"
          "hyprland"
        ];
        default = "hyprland";
      };
    };
  disabledModules = [ ];
  imports = lib.listFilePaths ./display;
  config = {
    environment.systemPackages = [
      pkgs.vulkan-tools
      pkgs.mesa-demos
    ];

    programs.dconf.enable = true;

    services.xserver.enable = lib.mkDefault false;

    # programs.light.enable = true;

    fonts.packages =
      (
        let
          fonts = config.home-manager.users.ash.desktop.theme.font.fonts;
        in
        foldl' (
          acc: font: if (fonts.${font}.package != null) then (acc ++ [ fonts.${font}.package ]) else acc
        ) [ ] (attrNames fonts)
      )
      ++ [
        pkgs.nerd-fonts.symbols-only
      ];

    # tty/console
    services.kmscon = {
      enable = true;
      useXkbConfig = true;
      config = {
        hwaccel = true;
      };
    };
  };
  meta = { };
}
