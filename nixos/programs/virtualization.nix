{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    assertions = [
      {
        assertion = config.virtualisation.libvirtd.enable -> config.programs.dconf.enable;
        message = "virt-manager requires dconf";
      }
    ];

    virtualisation.docker = {
      enable = false;
    };
    users.extraGroups.docker.members = ["ash"];

    virtualisation.libvirtd = {
      enable = lib.mkDefault false;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        ovmf = {
          enable = true;
          packages = with pkgs; [OVMFFull.fd];
        };
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    users.extraGroups."libvirtd".members = ["ash"];
  };
  meta = {};
}
