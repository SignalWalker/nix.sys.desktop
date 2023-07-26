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
    networking.networkmanager = {
      enable = true;
    };

    musnix = {
      enable = true;
      alsaSeq.enable = true;
      soundcardPciId = "00:1b.0";
      kernel = {
        realtime = false;
        packages = pkgs.linuxPackages_latest_rt;
      };
    };

    nix.extraOptions = ''
      builders-use-substitutes = true
    '';

    signal.machines."terra" = {
      nix.build.sshKey = "/run/nix/remote-build.sign";
    };
    systemd.tmpfiles.rules = [
      "C /run/nix/remote-build.sign - - - - /home/ash/.ssh/id_ed25519"
      "z /run/nix/remote-build.sign 0400 root root"
      "L /root/.ssh/known_hosts - - - - /home/ash/.ssh/known_hosts"
      "L /root/.ssh/id_ed25519 - - - - /home/ash/.ssh/id_ed25519"
    ];
  };
  meta = {};
}
