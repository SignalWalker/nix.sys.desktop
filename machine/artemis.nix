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
  imports = lib.signal.fs.path.listFilePaths ./artemis;
  config = {
    warnings = [
      "disabling systemd.network.wait-online"
    ];
    networking.networkmanager = {
      enable = true;
    };
    systemd.network.networks."eth".linkConfig.RequiredForOnline = "no";
    systemd.network.wait-online.enable = false;

    boot.supportedFilesystems = ["ntfs" "bcachefs"];

    musnix = {
      enable = true;
      alsaSeq.enable = true;
      soundcardPciId = "00:1f.3";
      kernel = {
        realtime = false;
        packages = pkgs.linuxPackages_latest_rt;
      };
    };

    nix = {
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };

    # environment.variables."EXTRA_SWAY_ARGS" = "-Dlegacy-wl-drm";

    signal.machines."terra" = {
      nix.build.sshKey = "/run/nix/remote-build.sign";
    };
    systemd.tmpfiles.rules = [
      "C /run/nix/remote-build.sign - - - - /home/ash/.ssh/id_ed25519"
      "z /run/nix/remote-build.sign 0400 root root"
      "L /root/.ssh/known_hosts - - - - /home/ash/.ssh/known_hosts"
      "L /root/.ssh/id_ed25519 - - - - /home/ash/.ssh/id_ed25519"
    ];

    signal.network.wireguard.tunnels."wg-airvpn" = {
      # TODO :: figure out a good way to keep this out of public repos
      addresses = ["10.171.122.61/32" "fd7d:76ee:e68f:a993:4543:e7b0:c146:840d/128"];
    };

    programs.kdeconnect = {
      enable = false;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    programs.weylus = {
      enable = true;
      users = ["ash"];
      openFirewall = true;
    };

    virtualisation.libvirtd = {
      enable = false;
    };

    services.clight = let
      backlight_curve = point_scale: bl_max: let
        xs = map (p: p / (point_scale * 1.0)) (std.lists.range 0 point_scale);
      in (map (x: x * x * bl_max) xs);
    in {
      enable = false;
      settings = {
        verbose = true;
        inhibit = {disabled = true;};
        screen = {disabled = true;};
        dpms = {disabled = true;};
        dimmer = {disabled = true;};
        sensor = {
          devname = "iio:device0";
          ac_regression_points = backlight_curve 10 0.5;
          batt_regression_points = backlight_curve 10 0.5;
        };
      };
    };
  };
  meta = {};
}
