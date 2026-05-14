{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = (lib.listFilePaths ./system) ++ [
    inputs.sysbase.nixosModules.default

    inputs.disko.nixosModules.disko

    inputs.impermanence.nixosModules.impermanence

    inputs.musnix.nixosModules.musnix
    inputs.auto-cpufreq.nixosModules.default
  ];
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
