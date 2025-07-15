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
        "elysium/project" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "elysium/git" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "elysium/var" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "elysium/backup" = {
          useTemplate = [ "archive" ];
          recursive = true;
        };
        "rpool/nixos/var/lib" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
      };
    };

    musnix = {
      soundcardPciId = "00:1f.3";
    };
  };
  meta = { };
}
