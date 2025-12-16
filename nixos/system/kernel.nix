{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins)
    isFunction
    isList
    all
    isAttrs
    isString
    tryEval
    match
    foldl'
    attrNames
    length
    ;
  filters = lib.mkOptionType {
    name = "filter function";
    check =
      val:
      (isFunction val)
      || (
        (isList val) && (all (val: (isAttrs val) && (isString val.loc) && (isFunction val.filter)) val)
      );
    merge =
      loc: defs:
      map (filter: {
        loc = filter.file;
        filter = filter.value;
      }) defs;
    # merge = loc: defs: builtins.foldl' (acc: def: (name: kp: (acc name kp) && (def.value name kp))) (name: kp: true) defs;
  };
  kernel = config.system.linuxKernel;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      system.linuxKernel = {
        packages = mkOption {
          type = types.raw;
          default = pkgs.linuxKernel.packages;
        };
        filter = mkOption {
          type = filters;
          default = name: kp: (builtins.match "linux_[0-9]+_[0-9]+" name) != null;
        };
        filtered = mkOption {
          type = types.listOf (types.raw);
          readOnly = true;
          default =
            let
              linux = lib.filterAttrs (
                name: kp: (tryEval kp).success && ((match "linux_.*" name) != null)
              ) kernel.packages;
            in
            (foldl'
              (
                acc: filter:
                let
                  res = {
                    inherit (filter) loc;
                    packages = lib.filterAttrs (filter.filter) acc.packages;
                  };
                in
                {
                  res = acc.res ++ [ res ];
                  packages = res.packages;
                }
              )
              {
                res = [
                  {
                    loc = "system.linuxKernel.packages";
                    packages = linux;
                  }
                ];
                packages = linux;
              }
              kernel.filter
            ).res;
        };
        allowed = mkOption {
          type = types.attrsOf types.raw;
          readOnly = true;
          default = (lib.last kernel.filtered).packages;
        };
        latest = mkOption {
          type = types.raw;
          readOnly = true;
          default = lib.last (
            lib.sort (a: b: lib.versionOlder a.kernel.version b.kernel.version) (
              builtins.attrValues kernel.allowed
            )
          );
        };
      };
    };
  disabledModules = [ ];
  imports = [ ];
  config = {
    assertions = [
      {
        assertion = (length (attrNames kernel.allowed)) > 0;
        message =
          "allowed kernels filtered to nothing; kernel filters: \n\t"
          ++ (lib.concatStringsSep "\n\t" (
            map (
              entry: "${entry.loc}: [ ${lib.concatStringsSep ", " (attrNames entry.packages)} ]"
            ) kernel.filtered
          ));
      }
    ];
    system.linuxKernel.filter =
      name: kp:
      (match "linux(_rt)?_([0-9]+_[0-9]+|zen|xanmod|lqx|hardened)(_hardened)?(_latest)?" name) != null;
    boot.kernelPackages = kernel.latest;
  };
  meta = { };
}
