{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ lib.signal.fs.path.listFilePaths ./hardware;
  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    services.thermald.enable = true;
    hardware.bluetooth = {
      enable = true;
    };
    boot.supportedFilesystems = ["ntfs"];
  };
  meta = {};
}
