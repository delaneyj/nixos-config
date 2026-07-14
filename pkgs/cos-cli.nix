{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cos-cli";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "estin";
    repo = "cos-cli";
    rev = "fe8c52016888302d6239ef53f1dbf876d8552dc2";
    hash = "sha256-IN+36GlQKyCbvK83lfospUWeaghqZ/sKtJZga8lIzF4=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "cosmic-protocols-0.2.0" = "sha256-xZ0ntzt9eAC95OiNdQmun0+yeHTWIPOvv21msvA0emc=";
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
