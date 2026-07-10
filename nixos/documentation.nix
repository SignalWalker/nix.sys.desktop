{
  ...
}:
{
  config = {
    documentation = {
      man = {
        enable = true;
      };
      doc = {
        enable = true;
      };
      dev = {
        enable = true;
      };
      nixos = {
        enable = false; # FIX :: build error 2026-10-04
        options = {
          warningsAreErrors = false;
        };
      };
    };
  };
}
