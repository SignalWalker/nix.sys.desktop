{
  inputs,
  config,
  lib,
  modulesPath,
  ...
}:
let
  inherit (builtins) elem;
  use_pstate = !(elem "intel_pstate=disable" config.boot.kernelParams);
in
{
  options = { };
  disabledModules = [ ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only

    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    "${inputs.nixos-hardware}/common/gpu/nvidia/turing"
  ]
  ++ lib.listFilePaths ./hardware;
  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # fileSystems."/windows" = {
    #   device = "/dev/disk/by-uuid/B050B49B50B46A2C";
    #   fsType = "ntfs";
    #   mountPoint = "/windows";
    #   options = [
    #     "uid=ash"
    #     "gid=users"
    #     "umask=227"
    #     "ro"
    #   ];
    # };

    boot.kernelParams = [
      "intel_pstate=disable"
    ];

    programs.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = if use_pstate then "powersave" else "schedutil";
          energy_performance_preference = "balance_power";
          turbo = "auto";
        };
        charger = {
          governor = if use_pstate then "performance" else "schedutil";
          energy_performance_preference = "balance_performance";
          turbo = "auto";
        };
      };
    };

    services.thermald = {
      enable = true;
    };

    services.tlp.enable = false;

    hardware.bluetooth = {
      enable = true;
    };

  };
  meta = { };
}
