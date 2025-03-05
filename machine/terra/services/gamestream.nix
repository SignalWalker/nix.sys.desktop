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
  imports = [];
  config = {
    services.sunshine = {
      enable = false;
      capSysAdmin = true;
      openFirewall = lib.mkForce false;
    };
    # services.x2goserver = {
    #   enable = true;
    # };
    services.xrdp = {
      enable = false;
      openFirewall = false;
      defaultWindowManager = "startplasma-x11";
    };

    # services.flatpak = {
    #   enable = false;
    # };
  };
  meta = {};
}
