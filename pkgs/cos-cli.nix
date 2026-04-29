{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cos-cli";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "estin";
    repo = "cos-cli";
    rev = "99cb0714bfd655a213f02c21302d50ae206df176";
    hash = "sha256-mFlkga2R4RKZRQ9wzTu/dM8lEfyICrm+be9a3SN1k2A=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "cosmic-protocols-0.2.0" = "sha256-ymn+BUTTzyHquPn4hvuoA3y1owFj8LVrmsPu2cdkFQ8=";
    };
  };

  meta = with lib; {
    description = "CLI utility for COSMIC Wayland toplevel and workspace management";
    homepage = "https://github.com/estin/cos-cli";
    license = licenses.mit;
    mainProgram = "cos-cli";
    platforms = platforms.linux;
  };
}
