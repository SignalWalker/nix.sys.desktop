{
  ...
}:
{
  config = {
    xdg = {
      terminal-exec = {
        enable = true;
        settings = {
          default = [
            "kitty.desktop"
          ];
        };
      };
      sounds.enable = true;
      # portal - see nixos/system/display
    };
  };
  meta = { };
}
