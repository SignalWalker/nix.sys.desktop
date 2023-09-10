{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  crowdsec = config.services.crowdsec;
  yaml = pkgs.formats.yaml {};
  mkYamlFile = name: src: (lib.mkOption {
    type = lib.types.path;
    readOnly = true;
    default = yaml.generate name src;
  });
in {
  options = with lib; {
    services.crowdsec = {
      enable = mkEnableOption "crowdsec";
      package = mkOption {
        type = types.package;
        default = pkgs.crowdsec;
      };
      user = mkOption {
        type = types.str;
        default = "crowdsec";
      };
      group = mkOption {
        type = types.str;
        default = "crowdsec";
      };
      dir = {
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/lib/${crowdsec.user}";
        };
        configuration = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/${crowdsec.user}";
        };
        runtime = mkOption {
          type = types.str;
          readOnly = true;
          default = "/run/${crowdsec.user}";
        };
        logs = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/log/${crowdsec.user}";
        };
      };
      config_paths = {
        hub_dir = mkOption {
          type = types.str;
          default = "${crowdsec.dir.configuration}/hub";
        };
        data_dir = mkOption {
          type = types.str;
          default = "${crowdsec.dir.state}/data";
        };
        notification_dir = mkOption {
          type = types.str;
          default = "${crowdsec.dir.configuration}/notifications";
        };
        plugin_dir = mkOption {
          type = types.str;
          default = "${crowdsec.dir.state}/plugins";
        };
      };
      listen = {
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
        };
        port = mkOption {
          type = types.port;
          default = 43507;
        };
        uri = mkOption {
          type = types.str;
          readOnly = true;
          default = "${crowdsec.listen.address}:${toString crowdsec.listen.port}";
        };
      };
      settings = mkOption {
        type = yaml.type;
        default = {};
      };
      settingsFile = mkYamlFile "config.yaml" crowdsec.settings;
      onlineApiCredentials = mkOption {
        type = yaml.type;
        default = {};
      };
      onlineApiCredentialsFile = mkYamlFile "online_api_credentials.yaml" crowdsec.onlineApiCredentials;
      localApiCredentials = mkOption {
        type = yaml.type;
        default = {};
      };
      localApiCredentialsFile = mkYamlFile "local_api_credentials.yaml" crowdsec.localApiCredentials;
      profiles = mkOption {
        type = yaml.type;
        default = {};
      };
      profilesFile = mkYamlFile "profiles.yaml" crowdsec.profiles;
      acquisitions = mkOption {
        type = types.attrsOf yaml.type;
        default = {};
      };
      acquisitionsDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "${crowdsec.dir.configuration}/acquisitions";
      };
      simulation = mkOption {
        type = yaml.type;
        default = {};
      };
      simulationFile = mkYamlFile "simulation.yaml" crowdsec.simulation;
      context = mkOption {
        type = yaml.type;
        default = {};
      };
      contextFile = mkYamlFile "context.yaml" crowdsec.context;
      extraGroups = mkOption {
        type = types.listOf types.str;
        description = "Extra groups to add to the crowdsec.service user.";
        default = [];
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf crowdsec.enable {
    users.users.${crowdsec.user} = {
      isSystemUser = true;
      createHome = true;
      home = crowdsec.dir.state;
      inherit (crowdsec) group;
    };
    users.groups.${crowdsec.group} = {};

    environment.systemPackages = [
      crowdsec.package
      # (pkgs.writeScriptBin "cscli-wrapped" ''
      #   #!/usr/bin/env sh
      #   sudo -u ${crowdsec.user} cscli "$@"
      # '')
    ];

    services.crowdsec = {
      settings = let
        configDir = crowdsec.dir.configuration;
        stateDir = crowdsec.dir.state;
        logsDir = crowdsec.dir.logs;
        runtimeDir = crowdsec.dir.runtime;
        # settings = crowdsec.settings;
      in {
        common = {
          daemonize = lib.mkForce true;
          pid_dir = runtimeDir;
          log_media = "file";
          log_level = "info";
          log_dir = logsDir;
          log_max_size = 500;
          log_max_age = 28;
          log_max_files = 3;
          compress_logs = true;
          working_dir = stateDir;
        };
        config_paths = {
          config_dir = configDir;
          data_dir = lib.mkForce crowdsec.config_paths.data_dir;
          notification_dir = lib.mkForce crowdsec.config_paths.notification_dir;
          plugin_dir = lib.mkForce crowdsec.config_paths.plugin_dir;
          hub_dir = lib.mkForce crowdsec.config_paths.hub_dir;
          simulation_path = lib.mkForce crowdsec.simulationFile;
          index_path = "${crowdsec.config_paths.hub_dir}/.index.json";
        };
        crowdsec_service = {
          enable = true;
          acquisition_dir = lib.mkForce crowdsec.acquisitionsDir;
          console_context_path = lib.mkForce crowdsec.contextFile;
          parser_routines = 1;
          buckets_routines = 1;
          output_routines = 1;
        };
        cscli = {
          output = "human";
          hub_branch = "wip_lapi";
          prometheus_uri = "http://127.0.0.1:${toString config.services.prometheus.port}";
        };
        db_config = {
          log_level = "info";
          type = "sqlite";
          use_wal = true;
          db_path = "${crowdsec.config_paths.data_dir}/crowdsec.db";
          flush = {
            max_items = 5000;
            max_age = "7d";
          };
          user = crowdsec.user;
        };
        api = {
          client = {
            insecure_skip_verify = false;
            credentials_path = lib.mkForce "${configDir}/local_api_credentials.yaml";
          };
          server = {
            enable = true;
            log_level = "info";
            listen_uri = lib.mkForce crowdsec.listen.uri;
            profiles_path = lib.mkForce crowdsec.profilesFile;
            use_forwarded_for_headers = false;
            console_path = "${configDir}/console.yaml";
            online_client = {
              credentials_path = lib.mkForce "${configDir}/online_api_credentials.yaml";
            };
          };
        };
        prometheus = {
          enabled = config.services.prometheus.enable;
          level = "full";
          listen_port = config.services.prometheus.port;
          listen_addr = "127.0.0.1"; # TODO
        };
      };
      localApiCredentials = {
        url = lib.mkForce "http://${crowdsec.listen.uri}";
      };
      profiles = {
        name = "default_ip_remediation";
        filters = [
          "Alert.Remediation == true && Alert.GetScope() == \"Ip\""
        ];
        decisions = [
          {
            type = "ban";
            duration = "4h";
          }
        ];
        on_success = "break";
      };
      acquisitions = {
        nginx = {
          filenames = [
            "/var/log/nginx/*.log"
            "./tests/nginx/nginx.log"
          ];
          labels.type = "nginx";
        };
        syslog = {
          filenames = [
            "/var/log/auth.log"
            "/var/log/syslog"
          ];
          labels.type = "syslog";
        };
      };
      simulation = {
        simulation = false;
      };
    };

    environment.etc =
      {
        "${crowdsec.user}/config.yaml" = {
          source = crowdsec.settingsFile;
          inherit (crowdsec) user group;
        };
      }
      // (std.mapAttrs' (name: acq: {
          name = "${crowdsec.user}/acquisitions/${name}.yaml";
          value = {
            source = yaml.generate "${name}.yaml" acq;
          };
        })
        crowdsec.acquisitions);

    systemd.tmpfiles.rules = let
      user = crowdsec.user;
      group = crowdsec.group;
      mode = "0750";
    in ((map
        (dirName: let
          dir = crowdsec.config_paths.${dirName};
        in "d ${dir} ${mode} ${user} ${group} - -")
        (attrNames crowdsec.config_paths))
      ++ [
        "L+ ${crowdsec.dir.configuration}/patterns - - - - ${crowdsec.package}/share/crowdsec/config/patterns"
      ]);

    systemd.services."crowdsec-setup" = let
      cscli = "${crowdsec.package}/bin/cscli -c ${crowdsec.settingsFile}";
      crowdsecCmd = "${crowdsec.package}/bin/crowdsec -c ${crowdsec.settingsFile}";
    in {
      after = ["syslog.target" "network.target" "remote-fs.target" "nss-lookup.target"];
      partOf = ["crowdsec.service"];
      path = [crowdsec.package];
      environment = {
        LC_ALL = "C";
        LANG = "C";
      };
      serviceConfig = {
        RuntimeDirectory = crowdsec.user;
        StateDirectory = crowdsec.user;
        LogsDirectory = crowdsec.user;
        ConfigurationDirectory = crowdsec.user;
        Type = "oneshot";
        RemainAfterExit = true;
        User = crowdsec.user;
        Group = crowdsec.group;
      };
      script = let
        configDir = crowdsec.dir.configuration;
        install = "install -o ${crowdsec.user} -g ${crowdsec.group}";
      in ''
        set -e

        ${cscli} hub update

        if [[ ! -e "${configDir}/local_api_credentials.yaml" ]]; then
          ${install} -m 0640 -T ${crowdsec.localApiCredentialsFile} "${configDir}/local_api_credentials.yaml"
        fi
        if [[ ! -e "${configDir}/online_api_credentials.yaml" ]]; then
          ${install} -m 0640 -T ${crowdsec.onlineApiCredentialsFile} "${configDir}/online_api_credentials.yaml"
        fi

        # ${cscli} capi register
        # ${cscli} machines add -a

        ${crowdsecCmd} -t -error
      '';
    };

    systemd.services."crowdsec" = {
      after = ["crowdsec-setup.service"];
      requires = ["crowdsec-setup.service"];
      wantedBy = ["multi-user.target"];
      path = [crowdsec.package];
      environment = {
        LC_ALL = "C";
        LANG = "C";
      };
      serviceConfig = {
        RuntimeDirectory = crowdsec.user;
        StateDirectory = crowdsec.user;
        LogsDirectory = crowdsec.user;
        ConfigurationDirectory = crowdsec.user;
        Type = "notify";
        ExecStart = "${crowdsec.package}/bin/crowdsec -c ${crowdsec.settingsFile}";
        ExecReload = "/usr/bin/env kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = 60;
        User = crowdsec.user;
        Group = crowdsec.group;
        SupplementaryGroups = crowdsec.extraGroups;
      };
    };
  };
  meta = {};
}
