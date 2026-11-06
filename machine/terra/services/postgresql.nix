{
  config,
  pkgs,
  lib,
  ...
}:
let
  pg = config.services.postgresql;
  pgbck = config.services.postgresqlBackup;
  shouldUpgrade = pg.finalPackage.psqlSchema != pkgs.postgresql.psqlSchema;
in
{
  config = {
    warnings = lib.mkIf shouldUpgrade [
      "postgresql upgrade available (${pg.package.psqlSchema} -> ${pkgs.postgresql.psqlSchema}); use `sudo upgrade-pg-cluster` to upgrade"
    ];
    services.postgresql = {
      enable = true;
      enableJIT = true;
      package = pkgs.postgresql_17;
      extensions = ps: [
      ];
    };
    services.postgresqlBackup = {
      enable = pg.enable;
      location = "/elysium/backup/postgres";
      compression = "zstd";
      compressionLevel = if pgbck.compression == "zstd" then 19 else 9;
    };
    environment.systemPackages = [
      pg.finalPackage.pg_config
    ] ++ (lib.optionals shouldUpgrade [
      (
        let
          newPg = pkgs.postgresql.withPackages pg.extensions;
        in
        pkgs.writeScriptBin "upgrade-pg-cluster" ''
          set -eux
          # XXX it's perhaps advisable to stop all services that depend on postgresql
          systemctl stop postgresql

          export NEWDATA="/var/lib/postgresql/${newPg.psqlSchema}"

          export NEWBIN="${newPg}/bin"

          export OLDDATA="${pg.dataDir}"
          export OLDBIN="${pg.finalPackage}/bin"

          install -d -m 0700 -o postgres -g postgres "$NEWDATA"
          cd "$NEWDATA"
          sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs pg.initdbArgs}

          sudo -u postgres $NEWBIN/pg_upgrade \
            --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            --old-bindir $OLDBIN --new-bindir $NEWBIN \
            --jobs $(nproc) \
            "$@"
        ''
      )
    ]);
  };
  meta = { };
}
