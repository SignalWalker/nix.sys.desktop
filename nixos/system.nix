{
  pkgs,
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./system;
  config = {
    musnix = {
      enable = true;
      alsaSeq.enable = true;
      rtcqs.enable = true;
      kernel = {
        realtime = false;
        packages = pkgs.linuxPackages_latest_rt;
      };
    };

    services.upower = {
      enable = true;
      criticalPowerAction = "PowerOff";
    };
  };
  meta = { };
}

