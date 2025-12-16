{
  ...
}:
{
  config = {
    # userspace manager for mounting usb devices, etc.
    services.udisks2 = {
      enable = true;
      settings = {
        "udisks2.conf" = {
        };
        "mount_options.conf" = {
          defaults = {
            btrfs_defaults = "compress=zstd";
          };
        };
      };
    };
  };
  meta = { };
}
