{
  config,
  pkgs,
  lib,
  ...
}:
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      boot.loader.configurationLimit = mkOption {
        type = types.int;
        default = 16;
      };
    };
  disabledModules = [ ];
  imports = [ ];
  config = {
    boot.loader = {
      systemd-boot = {
        enable = false;
        configurationLimit = config.boot.loader.configurationLimit;
        consoleMode = "auto";
      };
      grub = {
        enable = true;
        efiSupport = true;
        zfsSupport = config.boot.supportedFilesystems.zfs or false;
        configurationLimit = config.boot.loader.configurationLimit;
        theme = lib.mkDefault pkgs.nixos-grub2-theme;
        useOSProber = lib.mkDefault false;
        default = 0;
      };
    };

    boot.plymouth = {
      enable = false;
      theme = "tribar";
    };

    boot.crashDump = {
      enable = true;
    };
  };
  meta = { };
}
