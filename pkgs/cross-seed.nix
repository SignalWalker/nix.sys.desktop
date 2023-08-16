{
  inputs,
  pkgs,
  ...
}:
# inputs.napalm.legacyPackages.${pkgs.system}.buildPackage inputs.cross-seed {
#   nativeBuildInputs = [pkgs.python311Packages.python];
# }
pkgs.buildNpmPackage {
  name = "cross-seed";
  src = inputs.cross-seed;
  nativeBuildInputs = [pkgs.python311Packages.python];
  npmDepsHash = "sha256-TexcJ7rYUe0UxE1XlLQ1z59NjcW5a2rnxsKegecRhHI=";
}
