{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  xserver = config.services.xserver;
  manager = config.services.desktopManager.manager;
in {
  options = with lib; {
    services.desktopManager.manager = mkOption {
      type = types.enum ["plasma6" "sway" "river" "hyprland"];
      default = "hyprland";
    };
  };
  disabledModules = [];
  imports = lib.listFilePaths ./display;
  config = {
    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
    ];

    programs.dconf.enable = true;

    services.xserver.enable = lib.mkDefault false;

    programs.light.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };

    fonts.packages =
      (let
        fonts = config.home-manager.users.ash.desktop.theme.font.fonts;
      in
        foldl' (acc: font:
          if (fonts.${font}.package != null)
          then (acc ++ [fonts.${font}.package])
          else acc) [] (attrNames fonts))
      ++ [
        pkgs.nerd-fonts.symbols-only
      ];

    # tty/console
    services.kmscon = let
      fontCfg = config.home-manager.users.ash.desktop.theme.font;
    in {
      enable = false; # FIX :: breaks display manager as of 2025-04-02
      hwRender = false;
      useXkbConfig = true;
      fonts = map (font: {
        name = font.name;
        package = font.package;
      }) (fontCfg.terminal ++ fontCfg.symbols);
    };
  };
  meta = {};
}