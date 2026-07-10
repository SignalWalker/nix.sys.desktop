{
  config,
  lib,
  ...
}:
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      environment = {
        defaultPersistMountpoint = mkOption {
          type = types.str;
        };
      };
      system.persist = {
        defaultMount = mkOption {
          type = types.str;
          default = config.environment.defaultPersistMountpoint;
        };
      };
    };
  config =
    let
      env = config.environment;
      defaultMnt = env.defaultPersistMountpoint;
    in
    {
      environment.persistence = {
        ${defaultMnt} = {
          enable = true;
          hideMounts = true;
          directories = [
            # network
            "/etc/NetworkManager/system-connections"
            "/var/lib/iwd"
            "/var/lib/wgautomesh"

            # system
            "/var/db/sudo/lectured" # which users have received the lecture sudo outputs on first use
            "/var/lib/nixos"
            ## greeter
            "/var/cache/tuigreet" # last-logged-in user
            "/var/lib/regreet" # last-logged-in user
            ## systemd
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/timers"
            ## fwupd
            "/var/lib/fwupd"
            "/etc/fwupd"
            ## ssh
            "/etc/ssh/authorized_keys.d"

            # hardware
            "/var/lib/upower"
            "/var/lib/bluetooth"
            "/var/lib/systemd/backlight"

            # virtualization
            "/var/lib/docker"
            "/var/lib/lxc"
            "/var/lib/libvirt"
          ];
          files = [
            "/etc/machine-id"
            # ssh keys
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
          ];
        };
      };
    };
  meta = { };
}
