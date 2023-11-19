{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  guix = config.services.guix;
in {
  options = with lib; {
    services.guix = {
      enable = mkEnableOption "GNU Guix";
      package = mkPackageOption pkgs "guix" {};
      user = mkOption {
        type = types.str;
        default = "guix";
      };
      group = mkOption {
        type = types.str;
        default = "guix";
      };
      dir = {
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/lib/${guix.user}";
        };
        store = mkOption {
          type = types.str;
          readOnly = true;
          default = "/gnu/store";
        };
        configuration = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/${guix.user}";
        };
      };
      build = {
        group = mkOption {
          type = types.str;
          default = "guixbuild";
          description = "Group used by the Guix build pool.";
        };
        userAmount = mkOption {
          type = types.ints.unsigned;
          default = 12;
        };
      };
      gc = {
        enable = mkEnableOption "automatic garbage collection service";
        args = mkOption {
          type = types.listOf types.str;
          # these are from the upstream guix-gc.service
          default = [
            "-d 1m"
            "-F 10G"
          ];
        };
        dates = mkOption {
          type = types.str;
          default = "03:15";
          example = "weekly";
        };
      };
      publish = {
        enable = mkEnableOption "subsituter service";
        # TODO
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf guix.enable {
    environment.systemPackages = [pkgs.guix];

    users.users = let
      genBuildUser = id: {
        name = "guixbuilder${toString id}";
        group = guix.build.group;
        isSystemUser = true;
      };
    in
      listToAttrs (map (user: {
        name = user.name;
        value = user;
      }) (genList genBuildUser guix.build.userAmount));
  };
  meta = {};
}
