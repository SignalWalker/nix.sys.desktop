{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  xserver = config.services.xserver;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./display;
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
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "wlr"
            "gtk"
          ];
        };
      };
    };

    fonts.packages =
      (let
        fonts = config.home-manager.users.ash.desktop.theme.font.fonts;
      in
        foldl' (acc: font:
          if (fonts.${font}.package != null)
          then (acc ++ [fonts.${font}.package])
          else acc) [] (attrNames fonts))
      ++ (with pkgs; [
        (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      ]);

    # tty/console
    services.kmscon = let
      fontCfg = config.home-manager.users.ash.desktop.theme.font;
    in {
      enable = true;
      hwRender = true;
      useXkbConfig = true;
      fonts = map (font: {
        name = font.name;
        package = font.package;
      }) (fontCfg.terminal ++ fontCfg.symbols);
    };
  };
  meta = {};
}
