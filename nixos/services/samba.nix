{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  wsdd = config.services.samba-wsdd;
  samba = config.services.samba;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.samba-wsdd = {
      enable = samba.enable;
      openFirewall = true;
      workgroup = "WORKGROUP";
    };
    services.samba = {
      enable = false;
      openFirewall = true;
      settings = {
        "workgroup" = wsdd.workgroup;
        "server string" = config.networking.hostName;
        "netbios name" = config.networking.hostName;

        "server min protocol" = "SMB2_02";
        "hosts allow" = ["192.168.0." "127.0.0.1" "localhost"];
        "hosts deny" = "0.0.0.0/0";

        "guest account" = "nobody";
        "map to guest" = "bad user";

        "usershare path" = "/var/lib/samba/usershares";
        "usershare max shares" = 100;
        "usershare allow guests" = true;
        "usershare owner only" = true;
      };
    };

    networking.firewall.allowPing = lib.mkDefault samba.enable;
    # networking.firewall = {
    #   allowedTCPPorts = [ 5357 ];
    #   allowedUDPPorts = [ 3702 ];
    # };
  };
  meta = {};
}
