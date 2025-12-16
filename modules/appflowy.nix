{
  config,
  pkgs,
  lib,
  ...
}:
let
  appflowy = config.services.appflowy;
in
{
  options =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        ;
    in
    {
      services.appflowy = {
        enable = mkEnableOption "appflowy";
        package = mkPackageOption pkgs "appflowy" { };
      };
    };
  config = lib.mkIf appflowy.enable {

  };
}
