{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "0.71.1";

  src = ./.;
  npmDepsHash = "sha256-60CZv00M5bMtr4t9I4+ne7IvndXiO00C96XOxpRpVHI=";

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/pi-dev/node_modules/@mariozechner/pi-coding-agent/dist/cli.js $out/bin/pi
  '';

  meta = {
    description = "Pi coding agent CLI";
    homepage = "https://github.com/badlogic/pi-mono";
    mainProgram = "pi";
  };
}
