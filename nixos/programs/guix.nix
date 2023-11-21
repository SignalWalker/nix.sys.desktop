{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  guix = config.services.guix;
in {
  options = with lib; {
    services.guix = {
      enable = mkEnableOption "GNU Guix";
      package = mkPackageOption pkgs "guix" {};
      dir = {
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/guix";
        };
        store = mkOption {
          type = types.str;
          readOnly = true;
          default = "/gnu/store";
        };
        configuration = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/guix";
        };
      };
      profiles = {
        user = mkOption {
          type = types.attrsOf types.str;
          readOnly = true;
          default = {
            "current-guix" = "\${XDG_CONFIG_HOME}/guix/current";
            "guix-profile" = "$HOME/.guix-profile";
          };
        };
      };
      build = {
        group = mkOption {
          type = types.str;
          default = "guixbuild";
          description = "Group used by the Guix build pool.";
        };
        userAmount = mkOption {
          type = types.ints.unsigned;
          default = 12;
        };
        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };
      gc = {
        enable = mkEnableOption "automatic garbage collection service";
        args = mkOption {
          type = types.listOf types.str;
          # these are from the upstream guix-gc.service
          default = [
            "-d 1m"
            "-F 10G"
          ];
        };
        dates = mkOption {
          type = types.str;
          default = "03:15";
          example = "weekly";
        };
      };
      publish = {
        enable = mkEnableOption "subsituter service";
        # TODO
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf guix.enable (lib.mkMerge [
    {
      environment.systemPackages = [pkgs.guix];

      users.users = let
        genBuildUser = id: {
          name = "guixbuilder${toString id}";
          group = guix.build.group;
          isSystemUser = true;
        };
      in
        listToAttrs (map (user: {
          name = user.name;
          value = user;
        }) (genList genBuildUser guix.build.userAmount));
      users.groups.${guix.build.group} = {};

      systemd.services."guix-daemon" = {
        environment = {
          GUIX_LOCPATH = "${guix.dir.state}/profiles/per-user/root/guix-profile/lib/locale";
          LC_ALL = "en_US.utf8";
        };
        script = ''
          ${lib.getExe' guix.package "guix-daemon"} \
            --build-users-group=${guix.build.group} \
            ${std.escapeShellArgs guix.build.extraArgs}
        '';
        unitConfig = {
          RequiresMountsFor = [
            guix.dir.state
            guix.dir.store
          ];
        };
        serviceConfig = {
          OOMPolicy = "continue";
          StandardOutput = "syslog";
          StandardError = "syslog";
          Restart = "always";
          TasksMax = 8192;
        };
        wantedBy = ["multi-user.target"];
      };
      systemd.sockets."guix-daemon" = {
        before = ["multi-user.target"];
        listenStreams = ["${guix.dir.state}/daemon-socket/socket"];
        unitConfig = {
          RequiresMountsFor = [
            guix.dir.state
            guix.dir.store
          ];
          ConditionPathIsReadWrite = "${guix.dir.state}/daemon-socket";
        };
        wantedBy = ["socket.target"];
      };
      systemd.mounts = [
        {
          before = ["guix-daemon.service"];
          what = guix.dir.store;
          where = guix.dir.store;
          type = "none";
          options = "bind,ro";

          unitConfig.DefaultDependencies = false;
          wantedBy = ["guix-daemon.service"];
        }
      ];

      system.activationScripts.guix-authorize-keys = ''
        for official_server_keys in ${guix.package}/share/guix/*.pub; do
          ${std.getExe' guix.package "guix"} archive --authorize < $official_server_keys
        done
      '';

      system.userActivationScripts.guix-activate-user-profiles.text = let
        linkProfileToPath = acc: profile: location: let
          guixProfile = "${guix.dir.state}/profiles/per-user/\${USER}/${profile}";
        in
          acc
          + ''
            [ -d "${guixProfile}" ] && ln -sf "${guixProfile}" "${location}"
          '';

        activationScript = std.foldlAttrs linkProfileToPath "" guix.profiles.user;
      in ''
        XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
        # Linking the usual Guix profiles into the home directory.
        ${activationScript}
      '';

      environment.sessionVariables.GUIX_LOCPATH = std.makeSearchPath "lib/locale" (attrValues guix.profiles.user);
      environment.profiles = lib.mkBefore (attrValues guix.profiles.user);
    }
    (lib.mkIf guix.gc.enable {
      systemd.services."guix-gc" = {
        startAt = guix.gc.ddates;
        script = "${std.getExe' guix.package "guix"} gc ${std.escapeShellArgs guix.gc.args}";
        serviceConfig = {
          Type = "oneshot";

          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateNetworks = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelTunables = true;
          SystemCallFilter = [
            "@default"
            "@file-system"
            "@basic-io"
            "@system-service"
          ];
        };
      };
      systemd.timers."guix-gc".timerConfig.Persistent = true;
    })
  ]);
  meta = {};
}
