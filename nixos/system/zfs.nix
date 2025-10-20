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
  imports = lib.listFilePaths ./zfs;
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
          hourly = 24;
          daily = 14;
          monthly = 1;
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

