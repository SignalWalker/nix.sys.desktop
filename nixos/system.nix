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
  imports = lib.listFilePaths ./system;
  config = {
    musnix = {
      enable = true;
      alsaSeq.enable = true;
      rtcqs.enable = true;
      kernel = {
        realtime = false;
        packages = pkgs.linuxPkacages_latest_rt;
      };
    };
  };
  meta = { };
}