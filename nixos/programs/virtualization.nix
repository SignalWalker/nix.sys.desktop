{
  config,
  pkgs,
  lib,
  ...
}:
{
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

    environment.systemPackages = lib.mkIf config.virtualisation.containers.enable [
      pkgs.dive # look into docker image layers
      pkgs.podman-tui # status of containers in the terminal
      pkgs.podman-compose # start group of containers for dev
    ];

    users.extraGroups."docker".members = [ "ash" ];
    users.extraGroups."podman".members = [ "ash" ];

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
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    users.extraGroups."libvirtd".members = [ "ash" ];
  };
  meta = { };
}
