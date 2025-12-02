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
    environment.systemPackages = [
      pkgs.zfs-prune-snapshots
    ];
    services.sanoid = {
      enable = true;
      templates = {
        "standard" = {
          autoprune = true;
          autosnap = true;
          hourly = 4;
          daily = 4;
          monthly = 0;
          yearly = 0;
        };
        "archive" = {
          autoprune = true;
          autosnap = true;
          hourly = 4;
          daily = 4;
          monthly = 4;
          yearly = 0;
        };
      };
    };
  };
  meta = { };
}
