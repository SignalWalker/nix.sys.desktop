{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  guix = config.services.guix;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./programs;
  config = {
    services.guix = {
      enable = true;
      gc = {
        enable = true;
      };
    };
    users.groups.${guix.group}.members = ["ash"];

    environment.systemPackages = with pkgs; [
      fastfetch

      wineWowPackages.waylandFull
      winetricks
    ];

    programs.nix-ld = {
      enable = true;
    };
  };
  meta = {};
}
