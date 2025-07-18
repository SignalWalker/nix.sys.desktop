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

    virtualisation.waydroid = {
      enable = false;
    };

    environment.systemPackages = lib.mkIf config.virtualisation.containers.enable (with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for dev
    ]);

    users.extraGroups."docker".members = ["ash"];
    users.extraGroups."podman".members = ["ash"];

    virtualisation.podman = {
      autoPrune.enable = true;
      dockerSocket.enable = true;
    };

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
