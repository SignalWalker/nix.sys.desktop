{
  config,
  pkgs,
  lib,
  ...
}:
# FIX :: [--------] THIS IS ALMOST 100% COPIED FROM THE ARTEMIS CONFIG; FIX IT BEFORE RUNNING [--------]
{
  config =
    let
      disko = config.disko;
      partitions = disko.devices.disk.main.content.partitions;
      rootPart = partitions."root";
      subvols = rootPart.content.subvolumes;
    in
    lib.mkIf false (
      lib.mkMerge [
        (lib.mkIf disko.testMode {
          warnings = [ "building in disko test mode" ];
          environment.shellAliases = {
            "sull" = "sudo eza -lhaM --sort=type";
          };
          users.users = {
            ash = {
              initialPassword = "dummy";
            };
            root = {
              initialPassword = "dummy";
            };
          };
          services.greetd = {
            settings = {
              initial_session = {
                command = "fish";
                user = "ash";
              };
            };
          };
        })
        {
          environment = {
            btrfs.rootSupport = true;
            defaultPersistMountpoint = subvols."/persist".mountpoint;
          };

          fileSystems = {
            ${subvols."/persist".mountpoint}.neededForBoot = true;
            # (presumably) so we can get logs from boot
            ${subvols."/var/log".mountpoint}.neededForBoot = true;
          };
          virtualisation.vmVariantWithDisko = {
            virtualisation.fileSystems = {
              # NOTE :: disko-images makes the user directories before making the /home subvol https://github.com/nix-community/disko/issues/1157
              ${subvols."/home".mountpoint}.neededForBoot = true;
              # NOTE :: impermanence module gets mad at me if i don't set this
              ${subvols."/persist".mountpoint}.neededForBoot = true;
              # this one is just to be safe
              ${subvols."/var/log".mountpoint}.neededForBoot = true;
            };
          };
          boot.initrd = {
            systemd = {
              enable = true;
              # NOTE :: from https://www.notashelf.dev/posts/impermanence
              services."rollback-root" =
                let
                  maxRootAge = 14; # days
                  luksDeviceShell = ""; # FIX :: this
                in
                {
                  description = "Rollback BTRFS root subvolume to a pristine state";
                  wantedBy = [ "initrd.target" ];
                  after = [ "cryptsetup.target" ];
                  before = [ "sysroot.mount" ];
                  unitConfig.DefaultDependencies = "no";
                  serviceConfig.Type = "oneshot";
                  script = ''
                    set -eux

                    echo "Restoring /root-blank snapshot..."

                    if [[ ! -e ${luksDeviceShell} ]]; then
                      echo "Could not find " ${luksDeviceShell}
                      exit 1
                    fi

                    # make the mount dir...
                    mntpoint=$(mktemp -d)
                    subvol_abs_path="$mntpoint/root"
                    snapshot_abs_path="$mntpoint/root-blank"
                    archive_abs_path="$mntpoint/root-archive"

                    # We first mount the BTRFS root to $mntpoint
                    # so we can manipulate btrfs subvolumes.
                    mount -t btrfs -o subvol=/ ${luksDeviceShell} "$mntpoint"
                    trap 'umount "$mntpoint" && rm -d "$mntpoint"' EXIT

                    if [[ ! -e "$archive_abs_path" ]]; then
                      echo "Could not find root archive at $archive_abs_path"
                      exit 1
                    fi

                    if [[ ! -e "$snapshot_abs_path" ]]; then
                      echo "Could not find blank root snapshot at $snapshot_abs_path"
                      exit 1
                    fi

                    echo "$(date -Iseconds)" > "$archive_abs_path/last-boot-time"

                    # move old root to archive...
                    if [[ -e "$subvol_abs_path" ]]; then
                      timestamp=$(date --date="@$(stat -c %Y "$subvol_abs_path")" -Iseconds)
                      mv "$subvol_abs_path" "$archive_abs_path/$timestamp"
                    fi

                    # delete a subvolume and its descendents
                    delete_subvolume_recursively() {
                      IFS=$'\n'
                      for subvolume in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                        delete_subvolume_recursively "$mntpoint/$subvolume"
                      done
                      btrfs subvolume delete "$1"
                    }

                    # delete roots older than maxRootAge
                    for subvolume in $(find "$archive_abs_path/" -maxdepth 1 -mtime +${builtins.toString maxRootAge}); do
                      delete_subvolume_recursively "$subvolume"
                    done

                    # make a new root from the blank snapshot
                    btrfs subvolume snapshot "$snapshot_abs_path" "$subvol_abs_path"
                  '';
                };
            };
          };
          disko = {
            devices = {
              disk = {
                main = {
                  type = "disk";
                  device = "/dev/disk/by-id/nvme-eui.002538d51100a6ad";
                  content = {
                    type = "gpt";
                    partitions = {
                      ESP = {
                        label = "boot";
                        type = "EF00";
                        size = "512M";
                        priority = 0;
                        content = {
                          type = "filesystem";
                          format = "vfat";
                          mountpoint = "/boot";
                          mountOptions = [ "umask=0077" ];
                        };
                      };
                      swap = {
                        size = if disko.testMode then "64M" else "32G";
                        content = {
                          type = "swap";
                          discardPolicy = "both"; # TODO :: why?
                          resumeDevice = true;
                        };
                      };
                      root = {
                        size = "100%";
                        label = "root";
                        priority = 1;
                        settings = {
                          allowDiscards = true;
                        };
                        content =
                          let
                            rootName = "/root";
                            blankName = "${rootName}-blank";
                            # HACK :: these are just so the treesitter parser doesn't get mad at me (note the escaped quotes)
                            subvolAbsPath = "\"$mntpoint/${rootName}\"";
                            snapshotAbsPath = "\"$mntpoint/${blankName}\"";

                            rootDeviceShell = ""; # FIX :: this
                          in
                          {
                            type = "btrfs";
                            extraArgs = [ "-f" ];
                            postCreateHook = ''
                              (
                                echo "Snapshot /root as /root-blank..."
                                mntpoint=$(mktemp -d)
                                mount ${rootDeviceShell} "$mntpoint" -o subvol=/
                                trap 'umount "$mntpoint" && rm -d "$mntpoint"' EXIT
                                subvol_abs_path=${subvolAbsPath}
                                snapshot_abs_path=${snapshotAbsPath}

                                if btrfs subvolume show "$subvol_abs_path" > /dev/null 2>&1; then
                                  btrfs subvolume snapshot -r "$subvol_abs_path" "$snapshot_abs_path"
                                else
                                  echo ERROR: could not subvolume show "$subvol_abs_path" and therefore could not make "$snapshot_abs_path" snapshot
                                  exit 1
                                fi
                              )
                            '';

                            subvolumes =
                              let
                                mntDefaults = [
                                  "defaults"
                                  "compress=zstd"
                                  "noatime"
                                ];
                              in
                              {
                                ${rootName} = {
                                  mountpoint = "/";
                                  mountOptions = mntDefaults;
                                };
                                "/root-archive" = {
                                  mountpoint = "/.root-archive";
                                  mountOptions = mntDefaults;
                                };
                                "/nix" = {
                                  mountpoint = "/nix";
                                  mountOptions = mntDefaults;
                                };
                                "/gnu" = {
                                  mountpoint = "/gnu";
                                  mountOptions = mntDefaults;
                                };
                                "/home" = {
                                  mountpoint = "/home";
                                  mountOptions = mntDefaults;
                                };
                                "/var/log" = {
                                  mountpoint = "/var/log";
                                  mountOptions = mntDefaults;
                                };
                                "/persist" = {
                                  mountpoint = "/persist";
                                  mountOptions = mntDefaults;
                                };
                              };

                            content = {
                              type = "btrfs";
                              extraArgs = [ "-f" ];
                              subvolumes =
                                let
                                  mntDefaults = [
                                    "defaults"
                                    "compress=zstd"
                                    "noatime"
                                  ];
                                in
                                {
                                  ${rootName} = {
                                    mountpoint = "/";
                                    mountOptions = mntDefaults;
                                  };
                                  "/root-archive" = {
                                    mountpoint = "/.root-archive";
                                    mountOptions = mntDefaults;
                                  };
                                  "/nix" = {
                                    mountpoint = "/nix";
                                    mountOptions = mntDefaults;
                                  };
                                  "/gnu" = {
                                    mountpoint = "/gnu";
                                    mountOptions = mntDefaults;
                                  };
                                  "/swap" = {
                                    mountpoint = "/.swapvol";
                                    swap = {
                                      swapfile.size = if disko.testMode then "64M" else "32G";
                                    };
                                  };
                                  "/home" = {
                                    mountpoint = "/home";
                                    mountOptions = mntDefaults;
                                  };
                                  "/var/log" = {
                                    mountpoint = "/var/log";
                                    mountOptions = mntDefaults;
                                  };
                                  "/persist" = {
                                    mountpoint = "/persist";
                                    mountOptions = mntDefaults;
                                  };
                                };
                            };
                          };
                      };
                    };
                  };
                };
              };
              nodev = {
                "/tmp" = {
                  fsType = "tmpfs";
                  mountOptions = [
                    "size=50%"
                  ];
                };
              };
            };
          };
        }
      ]
    );
}
