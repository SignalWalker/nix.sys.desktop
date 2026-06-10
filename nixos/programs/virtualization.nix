{
  config,
  pkgs,
  lib,
  ...
}:
let
  libvirt = config.virtualisation.libvirtd;
  virtman = config.programs.virt-manager;
in
{
  config = {
    assertions = [
      {
        assertion = libvirt.enable -> config.programs.dconf.enable;
        message = "virt-manager requires dconf";
      }
      {
        assertion = virtman.enable -> libvirt.enable;
        message = "virt-manager requires libvirtd";
      }
    ];

    virtualisation.waydroid = {
      enable = false;
    };

    environment.systemPackages = lib.mkMerge [
      [
        pkgs.dnsmasq # libvirt networking
      ]
      (lib.mkIf config.virtualisation.containers.enable [
        pkgs.dive # look into docker image layers
        pkgs.podman-tui # status of containers in the terminal
        pkgs.podman-compose # start group of containers for dev
      ])
    ];

    users.extraGroups."docker".members = [ "ash" ];
    users.extraGroups."podman".members = [ "ash" ];

    virtualisation.containers = {
      containersConf.settings = {
        network = {
          dns_bind_port = 48462;
        };
      };
    };

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };

    virtualisation.libvirtd = {
      enable = lib.mkDefault true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
      dbus = {
        enable = true;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    users.extraGroups."libvirtd".members = [ "ash" ];
  };
  meta = { };
}
