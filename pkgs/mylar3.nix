{
  pkgs,
  inputs,
  ...
}: let
  pypkgs = pkgs.python311Packages;
  python = pypkgs.python;
in
  pypkgs.buildPythonApplication {
    name = "mylar3";
    src = inputs.mylar3;
    patches = [./mylar3/add-pyproject.patch];
    format = "pyproject";
    nativeBuildInputs = (with pkgs.python311Packages; [hatchling hatch-vcs]) ++ (with pkgs; []);
    propagatedBuildInputs =
      (with pkgs.python311Packages; [
        requests
        apscheduler
        cherrypy
        beautifulsoup4
        feedparser
        simplejson
        cfscrape
        pillow
        mako
      ])
      ++ (with pkgs; []);
    postInstall = ''
      cp -r "$src/data" "$out/${python.sitePackages}"
      install -Dm644 "$src/requirements.txt" "$out/${python.sitePackages}"
    '';
  }
