{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rtk";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "v${version}";
    hash = "sha256-TX4MtR/rq61wxHWYJAO2x3CYvZtkCoXynf45dRC+MVo=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  # Upstream tests assume writable user config directories and host tools.
  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    export HOME="$TMPDIR"
    export XDG_CONFIG_HOME="$TMPDIR/.config"
    mkdir -p "$HOME/.claude"
    $out/bin/rtk --version
    $out/bin/rtk gain >/dev/null
    $out/bin/rtk init -g --auto-patch >/dev/null

    runHook postInstallCheck
  '';

  meta = {
    description = "Rust Token Killer - CLI proxy to minimize LLM token consumption";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.mit;
    mainProgram = "rtk";
    platforms = lib.platforms.linux;
  };
}
