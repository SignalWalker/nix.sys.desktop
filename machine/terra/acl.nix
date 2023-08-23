{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  aclMap = config.system.aclMap;
  aclEntry = lib.types.submoduleWith {
    modules = [
      ({
        config,
        lib,
        pkgs,
        ...
      }: {
        options = with lib; {
          type = mkOption {
            type = types.enum ["user" "group"];
          };
          entity = mkOption {
            type = types.str;
          };
          read = mkEnableOption "read";
          write = mkEnableOption "write";
          execute = mkEnableOption "execute";
          __toString = mkOption {
            type = types.anything;
            readOnly = true;
            default = self: let
              typeStr =
                {
                  "user" = "u";
                  "group" = "g";
                }
                .${self.type};
              modeStr = "${
                if self.read
                then "r"
                else ""
              }${
                if self.write
                then "w"
                else ""
              }${
                if self.execute
                then "x"
                else ""
              }";
            in "${typeStr}:${self.entity}:${modeStr}";
          };
        };
        config = {};
      })
    ];
  };
  aclModule = lib.types.submoduleWith {
    modules = [
      ({
        config,
        lib,
        pkgs,
        name,
        ...
      }: {
        options = with lib; {
          path = mkOption {
            type = types.str;
            readOnly = true;
            default = name;
          };
          entries = mkOption {
            type = types.listOf aclEntry;
            default = [];
          };
          recursive = mkEnableOption "recursive";
          append = mkEnableOption "append";
          __toString = mkOption {
            type = types.anything;
            readOnly = true;
            default = self: let
              typeStr = "${
                if self.recursive
                then "A"
                else "a"
              }${
                if self.append
                then "+"
                else ""
              }";
              entries = concatStringsSep "," (map (entry: toString entry) self.entries);
            in "${typeStr} ${self.path} - - - - ${entries}";
          };
        };
        config = {
          # assertions = [
          #   {
          #     assertion = (substring 0 1 config.path) == "/";
          #     message = "acl path ${config.path} is not absolute";
          #   }
          # ];
        };
      })
    ];
  };
in {
  options = with lib; {
    system.aclMap = mkOption {
      type = types.attrsOf aclModule;
      default = {};
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    systemd.tmpfiles.rules = map (acl: assert (substring 0 1 acl) == "/"; toString aclMap.${acl}) (attrNames aclMap);
  };
  meta = {};
}
