{
  config,
  pkgs,
  lib,
  ...
}:
let
  wsdd = config.services.samba-wsdd;
  samba = config.services.samba;
in
{

  config = {
    networking.firewall = lib.mkMerge [
      (lib.mkIf samba.enable {
        allowedLocalTcpPorts = [
          139
          445
        ];
        allowedLocalUdpPorts = [
          137
          138
        ];
        allowPing = true; # FIX :: why???
      })
      (lib.mkIf wsdd.enable {
        allowedLocalTcpPorts = [
          5357
        ];
        allowedLocalUdpPorts = [
          3702
        ];
      })
    ];
    users.users.ash.extraGroups = lib.mkIf samba.enable [ "samba" ];
    services.samba-wsdd = {
      enable = samba.enable;
      openFirewall = false;
      workgroup = "WORKGROUP";
    };
    services.samba = {
      enable = false;
      package = pkgs.samba4Full;
      openFirewall = false;
      usershares.enable = true;
    };
  };
  meta = { };
}

