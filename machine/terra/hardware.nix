{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ lib.signal.fs.path.listFilePaths ./hardware;
  config = {};
  meta = {};
}
