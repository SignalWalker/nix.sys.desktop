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
  config = {
    services.sanoid = {
      datasets = {
        "rpool/nixos/home" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "rpool/nixos/var/lib" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "rpool/media/image" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "rpool/backup" = {
          useTemplate = [ "archive" ];
          recursive = true;
        };
      };
    };

  };
  meta = { };
}
