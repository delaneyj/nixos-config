{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "0.79.8";

  src = ./.;
  npmDepsHash = "sha256-R72Bjv2QFUhKbs/q2YB8MsmZ0BP45/gQ8Kfc90O7eSM=";
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
