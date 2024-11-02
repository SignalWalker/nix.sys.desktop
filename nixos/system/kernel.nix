{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  filterFn = lib.mkOptionType {
    name = "filter function";
    check = builtins.isFunction;
    merge = loc: defs: builtins.foldl' (acc: def: (name: kp: (acc name kp) && (def.value name kp))) (name: kp: true) defs;
  };
  kernel = config.system.linuxKernel;
in {
  options = with lib; {
    system.linuxKernel = {
      packages = mkOption {
        type = types.raw;
        default = pkgs.linuxKernel.packages;
      };
      filter = mkOption {
        type = filterFn;
        default = name: kp: (builtins.match "linux_[0-9]+_[0-9]+" name) != null;
      };
      allowed = mkOption {
        type = types.attrsOf types.raw;
        readOnly = true;
        default =
          lib.filterAttrs (name: kp: (builtins.tryEval kp).success && ((builtins.match "linux_.*" name) != null) && (kernel.filter name kp)) kernel.packages;
      };
      latest = mkOption {
        type = types.raw;
        readOnly = true;
        default =
          lib.last (lib.sort (a: b: lib.versionOlder a.kernel.version b.kernel.version) (builtins.attrValues kernel.allowed));
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    boot.kernelPackages = kernel.latest;
  };
  meta = {};
}
