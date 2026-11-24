{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "1.6.0";

  src = ./.;
  npmDepsHash = "sha256-Mjy027Rm2WIK04i2FDia6MFQWTOePNpMNyrmk4h0p4k=";
  makeCacheWritable = true;

  dontNpmBuild = true;
  # npm prune crashes on the published shrinkwrap ("from" argument undefined);
  # there are no devDependencies to prune anyway.
  dontNpmPrune = true;

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
