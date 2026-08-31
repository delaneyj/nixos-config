{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "0.84.4";

  src = ./.;
  npmDepsHash = "sha256-Aad5sMcK11s+J6Xj+pv3B9cqXTMuGzz9UQzJX2ZcCeM=";
  makeCacheWritable = true;

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/pi-dev/node_modules/@earendil-works/pi-coding-agent/dist/bundle/cli.js $out/bin/pi
  '';

  meta = {
    description = "Pi coding agent CLI";
    homepage = "https://github.com/badlogic/pi-mono";
    mainProgram = "pi";
  };
}
