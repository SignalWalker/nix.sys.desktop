{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./zfs;
  config = lib.mkIf config.zfs-root.boot.enable {
    boot.zfs = {
      package = pkgs.zfs_unstable;
    };
    environment.systemPackages = [
      pkgs.zfs-prune-snapshots
    ];
    services.sanoid = {
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
