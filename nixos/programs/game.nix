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
      remotePlay.openFirewall = true; # tcp 27036, udp 27031-27035
      localNetworkGameTransfers.openFirewall = true; # tcp 27040, udp 27036
      package = pkgs.steam;
      gamescopeSession = {
        enable = true;
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
