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
  imports = lib.signal.fs.path.listFilePaths ./zfs;
  config = {
    boot.zfs = {
      package = pkgs.zfs_unstable;
    };
  };
  meta = {};
}
