{
  pkgs,
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./zfs;
  config = {
    boot.zfs = {
      package = pkgs.zfs_unstable;
    };
    services.sanoid = {
      enable = true;
      templates = {
        "standard" = {
          autoprune = true;
          autosnap = true;
          hourly = 12;
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
