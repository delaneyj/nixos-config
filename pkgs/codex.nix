{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.156.1";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-r/RlOag6/4bjxixZK84sUNlTkfnfKJr68DpQwB0UUz0=";
  };

  hostSrc = fetchurl {
    url =
      "https://github.com/openai/codex/releases/download/"
      + "rust-v${version}/"
      + "codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "0266crz2rhwrdi7mb7bgv6n2bc8py4nl1rn9q00drgd0yslxlad9";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
    tar -xzf "$hostSrc"
  '';

  installPhase = ''
    install -Dm755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
    install -Dm755 codex-code-mode-host-x86_64-unknown-linux-musl \
      "$out/bin/codex-code-mode-host"
  '';

  meta = {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
}
