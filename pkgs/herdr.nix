{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "herdr";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
    hash = "sha256-PcgyiAc+TC08Z5ow576XvMqRQcb9F9u7khkULpXFklM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/herdr"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/herdr --version | grep -F "herdr ${version}"
  '';

  meta = {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://herdr.dev";
    license = lib.licenses.agpl3Plus;
    mainProgram = "herdr";
    platforms = [ "x86_64-linux" ];
  };
}
