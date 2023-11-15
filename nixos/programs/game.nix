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
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam;
      gamescopeSession = {
        enable = true;
      };
    };

    users.extraGroups."fusee".members = ["ash"];
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", GROUP="fusee"
    '';
  };
  meta = {};
}
