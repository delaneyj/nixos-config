{
  lib,
  stdenvNoCC,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  alsa-lib,
  curl,
  dbus,
  libglvnd,
  libpulseaudio,
  libsamplerate,
  SDL2,
  systemd,
  vulkan-loader,
  xorg,
}:

let
  runtimeLibraries = map lib.getLib [
    alsa-lib
    curl
    dbus
    libglvnd
    libpulseaudio
    libsamplerate
    SDL2
    systemd
    vulkan-loader
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXinerama
    xorg.libXi
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXxf86vm
  ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "picotron";
  version = "0.3.0d2";

  src = requireFile {
    name = "picotron_0.3.0d2_amd64.zip";
    sha256 = "sha256-deGRvkJJoItL7oLT0OAhJ67dMePZPQT+MLVTbY/PCEY=";
    message = ''
      Picotron is proprietary software. Download picotron_0.3.0d2_amd64.zip
      from your authorized Picotron account, then add it to the Nix store:

        nix-store --add-fixed sha256 ~/Downloads/picotron_0.3.0d2_amd64.zip
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = runtimeLibraries;
  runtimeDependencies = runtimeLibraries;

  unpackPhase = ''
    unzip "$src"
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/libexec/picotron" "$out/bin" \
      "$out/share/doc/picotron" "$out/share/icons/hicolor/128x128/apps" \
      "$out/share/applications"
    install -m755 picotron/picotron picotron/picotron_dyn "$out/libexec/picotron/"
    install -m644 picotron/picotron.dat "$out/libexec/picotron/"
    install -m644 picotron/license.txt picotron/picotron_manual.txt "$out/share/doc/picotron/"
    install -m644 picotron/lexaloffle-picotron.png \
      "$out/share/icons/hicolor/128x128/apps/picotron.png"

    makeWrapper "$out/libexec/picotron/picotron" "$out/bin/picotron" \
      --chdir "$out/libexec/picotron"
    makeWrapper "$out/libexec/picotron/picotron_dyn" "$out/bin/picotron-dyn" \
      --chdir "$out/libexec/picotron"

    cat > "$out/share/applications/picotron.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Name=Picotron
    Comment=Picotron workstation
    Exec=$out/bin/picotron
    Icon=picotron
    Categories=Development;Game;
    Terminal=false
    EOF

    runHook postInstall
  '';

  meta = {
    description = "Fantasy workstation by Lexaloffle Games";
    homepage = "https://www.lexaloffle.com/picotron.php";
    license = lib.licenses.unfree;
    mainProgram = "picotron";
    platforms = [ "x86_64-linux" ];
  };
})
