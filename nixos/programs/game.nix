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
        enable = false;
      };
    };

    users.extraGroups."fusee".members = ["ash"];
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", GROUP="fusee"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", GROUP="fusee"
    '';
  };
  meta = {};
}
