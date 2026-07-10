{
  inputs,
  config,
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
      # kernel = {
      #   realtime = true;
      # };
    };

    # PREEMPT_RT (required by musnix) requires kernel version >= 6.12
    system.linuxKernel.filter = name: kp: lib.versionOlder "6.11" kp.kernel.version;

    services.upower = {
      enable = true;
      criticalPowerAction = "PowerOff";
    };
  };
  meta = { };
}
