{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  sunshine = config.services.sunshine;
in {
  options = with lib; {
    services.sunshine = {
      enable = mkEnableOption "sunshine game streaming";
      package = mkOption {
        type = types.package;
        default = pkgs.sunshine;
        # default = pkgs.sunshine.override {
        #   cudaSupport = true;
        #   stdenv = pkgs.cudaPackages.backendStdenv;
        # };
      };
      # user = mkOption {
      #   type = types.str;
      #   default = "sunshine";
      # };
      # group = mkOption {
      #   type = types.str;
      #   default = "sunshine";
      # };
      # makeUser = mkOption {
      #   type = types.bool;
      #   default = sunshine.user == "sunshine";
      # };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf sunshine.enable {
    # users.users = lib.mkIf sunshine.makeUser {
    #   ${sunshine.user} = {
    #     isSystemUser = true;
    #     group = ${sunshine.group};
    #   };
    # };
    # users.groups = lib.mkIf sunshine.makeUser {
    #   ${sunshine.group} = {};
    # };
    systemd.user.services.sunshine = {
      unitConfig = {
        PartOf = ["graphical-session.target"];
      };
      startLimitIntervalSec = 500;
      startLimitBurst = 5;
      wantedBy = ["graphical-session.target"];
      # path = [sunshine.package "/etc/profiles/per-user/ash/bin"];
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
        Restart = "on-failure";
        RestartSec = "5s";
        # User = sunshine.user;
        # Group = sunshine.group;
      };
    };

    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${sunshine.package}/bin/sunshine";
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
    '';

    # networking.firewall = {
    #   allowedTCPPorts = [47989 47990];
    #   allowedUDPPorts = [47989 47990];
    # };
  };
  meta = {};
}
