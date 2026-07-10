{
  config,
  pkgs,
  lib,
  ...
}:
{
  options =
    let
      inherit (lib) mkOption mkEnableOption types;
    in
    {
      environment.btrfs = {
        rootSupport = mkEnableOption "support for btrfs on root";
      };
    };
  config =
    let
      btrfs = config.environment.btrfs;
    in
    lib.mkMerge [
      (lib.mkIf btrfs.rootSupport {
        # disable copy-on-write for the system journal
        systemd.tmpfiles.settings = {
          "10-var-log-journal" = {
            "/var/log/journal" = {
              "h".argument = "C";
            };
          };
        };
      })
    ];
  meta = { };
}
