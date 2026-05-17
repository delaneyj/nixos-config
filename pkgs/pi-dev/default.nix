{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  pname = "pi-dev";
  version = "0.74.0";

  src = ./.;
  npmDepsHash = "sha256-ZYg97YGH9N8tyaaTUhdO13LJTtuPzMypaB9CkMRZh2A=";

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
