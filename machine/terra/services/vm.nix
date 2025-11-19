{
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = [
      pkgs.quickemu
      pkgs.virt-viewer
    ];
  };
  meta = { };
}
