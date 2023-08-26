{
  pkgs,
  inputs,
  ...
}: let
  name = "kaizoku";
  src = inputs.kaizoku;
  pnpmDeps = pkgs.stdenvNoCC.mkDerivation {
    name = "${name}-pnpm-deps";
    inherit src;

    nativeBuildInputs = with pkgs; [
      jq
      moreutils
      nodePackages.pnpm
    ];

    installPhase = ''
      export HOME=$(mktemp -d)
      pnpm config set store-dir $out
      # use --ignore-script and --no-optional to avoid downloading binaries
      # use --frozen-lockfile to avoid checking git deps
      pnpm install --no-frozen-lockfile --no-optional --ignore-script

      # Remove timestamp and sort the json files
      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-UhB5PSbKr0y0kGvMz7GAuhfxHvRHkqOL1QEmgXwn6Go=";
  };
in
  pkgs.buildNpmPackage {
    inherit name src;
    nativeBuildInputs = with pkgs; [pnpm-lock-export];
    propagatedBuildInputs = with pkgs; [mangal];
    # inherit pnpmDeps;

    # preBuild = ''
    #   export HOME=$(mktemp -d)
    #   pnpm config set store-dir "$pnpmDeps"
    #   pnpm install --offline --no-frozen-lockfile --no-optional --ignore-script
    #   chmod -R +w ../node_modules
    #   pnpm rebuild
    # '';
    # postPatch = ''
    #   $[pkgs.pnpm-lock-export}/bin/pnpm-lock-export --schema "package-lock.json@v1"
    # '';

    npmDepsHash = "sha256-TexcJ7rYUe0UxE1XlLQ1z59NjcW5a2rnxsKegecRhHI=";
  }
