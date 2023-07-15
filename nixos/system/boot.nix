{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {
    boot.loader.configurationLimit = mkOption {
      type = types.int;
      default = 16;
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = config.boot.loader.configurationLimit;
        consoleMode = "auto";
      };
      # grub = {
      #   enable = lib.mkForce false;
      #   efiSupport = true;
      #   zfsSupport = any (fs: fs == "zfs") config.boot.supportedFileSystems;
      #   configurationLimit = config.boot.loader.configurationLimit;
      #   theme = pkgs.nixos-grub2-theme;
      # };
    };
  };
  meta = {};
}
