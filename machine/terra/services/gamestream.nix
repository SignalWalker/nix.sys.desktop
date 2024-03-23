{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  sunshine = config.services.sunshine;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./gamestream;
  config = {
    services.sunshine = {
      enable = true;
    };
    # services.x2goserver = {
    #   enable = true;
    # };
    services.xrdp = {
      enable = false;
      openFirewall = false;
      defaultWindowManager = "startplasma-x11";
    };

    services.flatpak = {
      enable = false;
    };
  };
  meta = {};
}
