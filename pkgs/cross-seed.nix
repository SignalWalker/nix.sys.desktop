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
  npmDepsHash = "sha256-wn0yxmLLxRnJt1EJiatL71QMyfYG6rpozDmSO90n8z0=";
}
