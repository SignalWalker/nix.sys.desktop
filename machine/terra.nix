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
  imports = lib.signal.fs.path.listFilePaths ./terra;
  config = {
    virtualisation.libvirtd = {
      enable = true;
    };
  };
  meta = {};
}
