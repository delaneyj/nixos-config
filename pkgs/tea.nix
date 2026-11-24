{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "tea";
  version = "0.16.0";

  src = fetchurl {
    url = "https://dl.gitea.com/tea/${version}/tea-${version}-linux-amd64";
    sha256 = "9c142c8a0b31485eea2387031c1c404f12b7141075eb4ffbd7ced49441590636";
  };

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/tea"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/tea --version
    $out/bin/tea api --help
    runHook postInstallCheck
  '';

  meta = {
    description = "Command-line tool to interact with Gitea";
    homepage = "https://gitea.com/gitea/tea";
    license = lib.licenses.mit;
    mainProgram = "tea";
    platforms = [ "x86_64-linux" ];
  };
}
