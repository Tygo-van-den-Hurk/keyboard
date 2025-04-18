{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  ...
}:

buildNpmPackage rec {
  pname = "ergogen";
  version = "4.1.0";

  forceGitDeps = true;

  src = fetchFromGitHub {
    owner = "ergogen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Y4Ri5nLxbQ78LvyGARPxsvoZ9gSMxY14QuxZJg6Cu3Y=";
  };

  npmDepsHash = "sha256-BQbf/2lWLYnrSjwWjDo6QceFyR+J/vhDcVgCaytGfl0=";
  makeCacheWritable = true;
  dontNpmBuild = true;
  npmPackFlags = [ "--ignore-scripts" ];
  NODE_OPTIONS = "--openssl-legacy-provider";

  meta = {
    description = "Ergonomic keyboard layout generator.";
    homepage = "https://ergogen.xyz";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Tygo-van-den-Hurk ];
  };
}
