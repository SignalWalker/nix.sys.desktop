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
    environment.systemPackages = with pkgs; [
      quickemu
      virt-viewer
    ];
  };
  meta = {};
}
