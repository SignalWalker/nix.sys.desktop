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
  imports = [ ];
  config = lib.mkIf false {
    users.users."tes3mp" = {
      isSystemUser = true;
      group = "tes3mp";
      home = "/var/lib/tes3mp";
      packages = [ pkgs.openmw-tes3mp ];
    };
    users.groups."tes3mp" = { };

    systemd.services."tes3mp" = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.openmw-tes3mp ];
      serviceConfig = {
        ConfigurationDirectory = "tes3mp";
        RuntimeDirectory = "tes3mp";
        StateDirectory = "tes3mp";
        LogsDirectory = "tes3mp";
        ExecStart = "${pkgs.openmw-tes3mp}/bin/tes3mp-server";
        RemainAfterExit = true;
        Restart = "always";
        RestartSec = 30;
        User = "tes3mp";
        Group = "tes3mp";
      };
    };
  };
  meta = { };
}
