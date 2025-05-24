{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = lib.signal.fs.path.listFilePaths ./zfs;
  config = {
    boot.zfs = {
      package = pkgs.zfsUnstable;
    };
    services.sanoid = {
      enable = true;
      templates = {
        "standard" = {
          autoprune = true;
          autosnap = true;
          hourly = 36;
          daily = 30;
          monthly = 3;
          yearly = 0;
        };
        "archive" = {
          autoprune = true;
          autosnap = true;
          hourly = 0;
          daily = 30;
          monthly = 12;
          yearly = 2;
        };
      };
    };
  };
  meta = { };
}
