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
  imports = lib.signal.fs.path.listFilePaths ./system;
  config = {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    fonts.packages = with pkgs; [
      (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    ];
  };
  meta = {};
}
