{
  inputs,
  pkgs,
  ...
}:
# inputs.napalm.legacyPackages.${pkgs.system}.buildPackage inputs.cross-seed {
#   nativeBuildInputs = [pkgs.python311Packages.python];
# }
pkgs.buildGoModule {
  name = "autobrr";
  src = inputs.autobrr;
  # nativeBuildInputs = [pkgs.python311Packages.python];
}
