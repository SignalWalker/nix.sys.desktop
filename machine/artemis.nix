{
  pkgs,
  lib,
  ...
}:
let
  std = pkgs.lib;
in
{
  imports = lib.listFilePaths ./artemis;
  config = {
    warnings = [
      # "disabling systemd.network.wait-online"
    ];
    networking.networkmanager = {
      enable = true;
    };
    systemd.network.networks."eth".linkConfig.RequiredForOnline = "no";
    # systemd.network.wait-online.enable = false;

    nix = {
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };

    # environment.variables."EXTRA_SWAY_ARGS" = "-Dlegacy-wl-drm";

    signal.machines."terra" = {
      nix.build.sshKey = "/run/nix/remote-build.sign";
    };
    systemd.tmpfiles.settings = {
      "10-nix-remote-build" = {
        "/run/nix/remote-build.sign" = {
          "C" = {
            argument = "/home/ash/.ssh/id_ed25519";
          };
          "z" = {
            mode = "0400";
            user = "root";
            group = "root";
          };
        };
      };
      "10-root-ssh" = {
        "/root/.ssh/known_hosts" = {
          "L" = {
            argument = "/home/ash/.ssh/known_hosts";
          };
        };
        "/root/.ssh/id_ed25519" = {
          "L" = {
            argument = "/home/ash/.ssh/id_ed25519";
          };
        };
      };
    };

    networking.wireguard.tunnels."wg-airvpn" = {
      # TODO :: figure out a good way to keep this out of public repos
      addresses = [
        "10.171.122.61/32"
        "fd7d:76ee:e68f:a993:4543:e7b0:c146:840d/128"
      ];
    };

    virtualisation.libvirtd = {
      enable = false;
    };

    services.clight =
      let
        backlight_curve =
          point_scale: bl_max:
          let
            xs = map (p: p / (point_scale * 1.0)) (std.lists.range 0 point_scale);
          in
          (map (x: x * x * bl_max) xs);
      in
      {
        enable = false;
        settings = {
          verbose = true;
          inhibit = {
            disabled = true;
          };
          screen = {
            disabled = true;
          };
          dpms = {
            disabled = true;
          };
          dimmer = {
            disabled = true;
          };
          sensor = {
            devname = "iio:device0";
            ac_regression_points = backlight_curve 10 0.5;
            batt_regression_points = backlight_curve 10 0.5;
          };
        };
      };
  };
  meta = { };
}
