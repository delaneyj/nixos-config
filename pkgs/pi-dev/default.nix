{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "0.87.1";

  src = ./.;
  npmDepsHash = "sha256-Bf0lbbCdCbLaJrYQBSnK7F3fH9EmhSlu++MY1TKwt2s=";
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
