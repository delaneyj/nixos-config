{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.144.1";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-hAka4gxl/MfUEg25fRvVfX/435x2Cft4HHjC671PWig=";
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
