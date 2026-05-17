{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.130.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-Fneee3hXUIp2ijbX1OCE7sM27COUbtcKmwlIm4+GEZA=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    install -Dm755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
  '';

  meta = {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
}
