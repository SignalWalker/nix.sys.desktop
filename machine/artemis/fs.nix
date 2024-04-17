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
    services.rpcbind = {
      enable = true;
    };
    systemd.mounts = [
      {
        type = "nfs";
        mountConfig = {
          Options = "noatime";
        };
        what = "server:/172.24.86.1";
        where = "/elysium";
      }
    ];
    systemd.automounts = [
      {
        wantedBy = ["multi-user.target"];
        automountConfig = {
          TimeoutIdleSec = "720";
        };
        where = "/elysium";
      }
    ];
  };
  meta = {};
}
