{
  pkgs,
  inputs,
  ...
}:
pkgs.python311Packages.buildPythonApplication {
  name = "mylar3";
  src = inputs.mylar3;
}
