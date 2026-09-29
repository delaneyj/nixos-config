{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.157.0";

  # The full "package" layout (bin/codex, codex-package.json, codex-path/,
  # codex-resources/) is required: since the app-server-daemon release line,
  # the CLI refuses to start without a complete local package next to its
  # executable ("this CLI has no complete local package"). This mirrors what
  # upstream install.sh extracts, including the top-level `codex` symlink.
  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-BC+FHqP8EIPEUVdSBSCUT8eQYytT68WA/JjqylWGKiU=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -a bin codex-package.json codex-path codex-resources "$out/"
    ln -sf bin/codex "$out/codex"
    chmod 0755 \
      "$out/bin/codex" \
      "$out/bin/codex-code-mode-host" \
      "$out/codex-path/rg"
    if [ -f "$out/codex-resources/bwrap" ]; then
      chmod 0755 "$out/codex-resources/bwrap"
    fi
  '';

  meta = {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
}
