{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "0.80.6";

  src = ./.;
  npmDepsHash = "sha256-eOS71R19TYqq5liLJBlFTOGlPUdlMzVHaV34zWPoHOM=";
  makeCacheWritable = true;

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/pi-dev/node_modules/@earendil-works/pi-coding-agent/dist/cli.js $out/bin/pi
  '';

  meta = {
    description = "Pi coding agent CLI";
    homepage = "https://github.com/badlogic/pi-mono";
    mainProgram = "pi";
  };
}
