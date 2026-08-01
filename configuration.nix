# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  whisperBaseEnModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };

  terminalDictate = pkgs.writeShellApplication {
    name = "terminal-dictate";
    runtimeInputs = with pkgs; [
      coreutils
      ffmpeg
      gnused
      whisper-cpp
      wl-clipboard
      wtype
    ];
    text = ''
      set -eu

      dur="''${1:-8}"
      tmp="$(mktemp -d)"
      trap 'rm -rf "$tmp"' EXIT

      ffmpeg -hide_banner -loglevel error \
        -f pulse -i default \
        -t "$dur" \
        -ar 16000 -ac 1 \
        "$tmp/in.wav"

      whisper-cli \
        -m ${whisperBaseEnModel} \
        -f "$tmp/in.wav" \
        -nt -np -otxt -of "$tmp/out" >/dev/null

      text="$(tr '\n' ' ' < "$tmp/out.txt" | sed 's/^ *//; s/ *$//')"

      printf '%s' "$text" | wl-copy
      wtype "$text"
    '';
  };

  terminalDictateToggle = pkgs.writeShellApplication {
    name = "terminal-dictate-toggle";
    runtimeInputs = with pkgs; [
      coreutils
      ffmpeg
      gnused
      procps
      whisper-cpp
      wl-clipboard
      wtype
    ];
    text = ''
      set -eu

      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/terminal-dictate"
      pid_file="$state_dir/ffmpeg.pid"
      wav_file="$state_dir/in.wav"
      out_file="$state_dir/out"

      mkdir -p "$state_dir"

      if [ -s "$pid_file" ]; then
        pid="$(cat "$pid_file")"
        rm -f "$pid_file"

        if ps -p "$pid" >/dev/null 2>&1; then
          kill -INT "$pid" >/dev/null 2>&1 || true
          for _ in $(seq 1 50); do
            ps -p "$pid" >/dev/null 2>&1 || break
            sleep 0.1
          done
        fi

        whisper-cli \
          -m ${whisperBaseEnModel} \
          -f "$wav_file" \
          -nt -np -otxt -of "$out_file" >/dev/null

        text="$(tr '\n' ' ' < "$out_file.txt" | sed 's/^ *//; s/ *$//')"
        rm -f "$wav_file" "$out_file.txt"

        printf '%s' "$text" | wl-copy
        wtype "$text"
        exit 0
      fi

      rm -f "$wav_file" "$out_file.txt"
      ffmpeg -hide_banner -loglevel error \
        -f pulse -i default \
        -ar 16000 -ac 1 \
        "$wav_file" &
      printf '%s' "$!" > "$pid_file"
    '';
  };

  unstablePkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/e7a3ca8092b61ff85b6a45bf863ea2b2d6a661b3.tar.gz";
        sha256 = "1h4jkfjbdp9y0alp86z38g60mqw7rzx89gn16dbvw8wn2z7r002j";
      })
      {
        config.allowUnfree = true;
      };
  chromePackage = unstablePkgs.google-chrome;
  cosmicScreenshotSaveAndCopy = pkgs.writeShellApplication {
    name = "cosmic-screenshot-save-and-copy";
    runtimeInputs = with pkgs; [
      coreutils
      cosmic-screenshot
      findutils
      wl-clipboard
    ];
    text = ''
      set -eu

      pictures_dir="$HOME/Pictures"
      marker="$(mktemp)"
      trap 'rm -f "$marker"' EXIT

      cosmic-screenshot --interactive=true --modal=true

      for _ in $(seq 1 20); do
        new_file="$(
          find "$pictures_dir" -maxdepth 2 -type f -name 'Screenshot_*.png' -newer "$marker" -print \
            | tail -n 1
        )"

        if [ -n "$new_file" ] && [ -f "$new_file" ]; then
          wl-copy --type image/png < "$new_file"
          exit 0
        fi

        sleep 0.1
      done
    '';
  };

  zoomAwareBrowser = pkgs.writeShellApplication {
    name = "zoom-aware-browser";
    text = ''
      first="''${1:-}"

      case "$first" in
        https://zoom.us/j/*|http://zoom.us/j/*|https://*.zoom.us/j/*|http://*.zoom.us/j/*)
          without_fragment="''${first%%#*}"
          path_query="''${without_fragment#*://*/j/}"
          meeting_id="''${path_query%%[?/#]*}"
          query=""
          password=""

          case "$without_fragment" in
            *\?*) query="''${without_fragment#*\?}" ;;
          esac

          if [ -n "$query" ]; then
            IFS='&' read -r -a query_pairs <<< "$query"
            for pair in "''${query_pairs[@]}"; do
              case "$pair" in
                pwd=*) password="''${pair#pwd=}" ;;
              esac
            done
          fi

          if [ -n "$meeting_id" ]; then
            zoom_url="zoommtg://zoom.us/join?action=join&confno=$meeting_id"
            if [ -n "$password" ]; then
              zoom_url="$zoom_url&pwd=$password"
            fi

            exec ${lib.getExe pkgs.zoom-us} "$zoom_url"
          fi
          ;;
      esac

      exec ${chromePackage}/bin/google-chrome-stable "$@"
    '';
  };

  zoomAwareBrowserDesktop = pkgs.makeDesktopItem {
    name = "zoom-aware-browser";
    desktopName = "Zoom-aware browser";
    exec = "${lib.getExe zoomAwareBrowser} %U";
    mimeTypes = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    categories = [
      "Network"
      "WebBrowser"
    ];
  };

  browserXdgOpen = pkgs.writeShellApplication {
    name = "xdg-open";
    text = ''
      case "''${1:-}" in
        http://*|https://*) exec ${lib.getExe zoomAwareBrowser} "$@" ;;
      esac

      exec ${lib.getExe' pkgs.xdg-utils "xdg-open"} "$@"
    '';
  };

  # Wrap Ghostty to disable GTK portal-based URI opens, which can fail silently
  # in COSMIC when clicking terminal URLs.
  ghosttyNoPortal = pkgs.writeShellApplication {
    name = "ghostty";
    text = ''
      export GTK_USE_PORTAL=0
      exec ${lib.getExe pkgs.ghostty} "$@"
    '';
  };

  discordPackage =
    pkgs.runCommand "discord-browser-aware-${lib.getVersion pkgs.discord}"
      { nativeBuildInputs = [ pkgs.makeWrapper ]; }
      ''
        mkdir -p "$out"
        cp -aL ${pkgs.discord}/. "$out/"
        chmod -R u+w "$out"

        wrapProgram "$out/bin/Discord" \
          --prefix PATH : ${
            lib.makeBinPath [
              browserXdgOpen
              pkgs.xdg-utils
            ]
          } \
          --set BROWSER ${lib.getExe zoomAwareBrowser} \
          --set GTK_USE_PORTAL 0 \
          --suffix XDG_DATA_DIRS : /run/current-system/sw/share

        wrapProgram "$out/bin/discord" \
          --prefix PATH : ${
            lib.makeBinPath [
              browserXdgOpen
              pkgs.xdg-utils
            ]
          } \
          --set BROWSER ${lib.getExe zoomAwareBrowser} \
          --set GTK_USE_PORTAL 0 \
          --suffix XDG_DATA_DIRS : /run/current-system/sw/share

        substituteInPlace "$out/share/applications/discord.desktop" \
          --replace-fail 'Exec=Discord' "Exec=$out/bin/Discord"
      '';

  cosCli = pkgs.callPackage ./pkgs/cos-cli.nix { };
  piDev = unstablePkgs.callPackage ./pkgs/pi-dev { };
  rtk = pkgs.callPackage ./pkgs/rtk.nix { };
  picotron = pkgs.callPackage ./pkgs/picotron.nix { };
  llamaCppVulkan = unstablePkgs.llama-cpp.override {
    vulkanSupport = true;
  };
  stableDiffusionCppVulkan = unstablePkgs.stable-diffusion-cpp-vulkan;
  vscodePackageRaw = unstablePkgs.vscode.overrideAttrs (_old: {
    version = "1.128.0";
    src = unstablePkgs.fetchurl {
      name = "VSCode_1.128.0_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/1.128.0/linux-x64/stable";
      hash = "sha256-qbTOl07MEMdFbamHl2O/CnpDJxC9JslaiaihaPKv9Xs=";
    };
  });
  vscodePackageBase = unstablePkgs.vscode-with-extensions.override {
    vscode = vscodePackageRaw;
    vscodeExtensions = [
      unstablePkgs.vscode-extensions.jdinhlife.gruvbox
      unstablePkgs.vscode-extensions.golang.go
      unstablePkgs.vscode-extensions.mhutchie.git-graph
      unstablePkgs.vscode-extensions.waderyan.gitblame
      unstablePkgs.vscode-extensions.biomejs.biome
      unstablePkgs.vscode-extensions.arrterian.nix-env-selector
      unstablePkgs.vscode-extensions.jnoortheen.nix-ide
      unstablePkgs.vscode-extensions.mkhl.direnv
    ]
    ++ unstablePkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "protobuf-vsc";
        publisher = "DrBlury";
        version = "1.6.6";
        sha256 = "uMyxdLptaLZBlLEugvYQgJTZCtysmnZix9faXsQfHGk=";
      }
      {
        name = "templ";
        publisher = "a-h";
        version = "0.0.35";
        sha256 = "WIBJorljcnoPUrQCo1eyFb6vQ5lcxV0i+QJlJdzZYE0=";
      }
      {
        name = "vscode-pull-request-github";
        publisher = "GitHub";
        version = "0.157.2026071304";
        sha256 = "2A4IM9EzAk8I4UV1OP8ecM25Km6mHfRS4UK9L2Dj1Rw=";
      }
      {
        name = "copilot-chat";
        publisher = "GitHub";
        version = "0.48.1";
        sha256 = "eFLfYMFxvgtZtmwLsxfneMjD4jOg8/Uk0Eu/6+A6odY=";
      }
      {
        name = "gitea-vscode";
        publisher = "ijustdev";
        version = "2.1.0";
        sha256 = "+6abVHameFVUJ5lFeS9qzb+XYlhsJV6v05eca4szpU4=";
      }
      {
        name = "nix-extension-pack";
        publisher = "pinage404";
        version = "3.0.0";
        sha256 = "1ndhz51p1fxf42ch1awf7cydi5jryff5v72zckl1mi3j17ldsrbi";
      }
    ];
  };
  vscodePackage = pkgs.runCommand "vscode-home-extensions-${lib.getVersion vscodePackageBase}" { } ''
        mkdir -p "$out"
        cp -a ${vscodePackageBase}/. "$out/"
        chmod -R u+w "$out"
        rm -f "$out/bin/code"
        base_ext_dir="$(${pkgs.gnused}/bin/sed -n 's/.*--extensions-dir \([^ ]*\).*/\1/p' ${vscodePackageBase}/bin/code | ${pkgs.coreutils}/bin/head -n 1)"
        cat > "$out/bin/code" <<'EOF'
    #!@BASH@
    set -euo pipefail
    export PATH="@NIX_BIN@:$PATH"
    base_ext_dir="@BASE_EXT_DIR@"
    ext_dir="''${VSCODE_EXTENSIONS:-$HOME/.vscode/extensions}"
    mkdir -p "$ext_dir"
    if [ -d "$base_ext_dir" ]; then
      for src in "$base_ext_dir"/*; do
        [ -d "$src" ] || continue
        name="$(basename "$src")"
        target="$ext_dir/$name"
        if [ -L "$target" ] && [ "$(readlink "$target")" != "$src" ]; then
          ln -sfn "$src" "$target"
        elif [ ! -e "$target" ]; then
          ln -s "$src" "$target"
        fi
      done
    fi
    if [ -f "$base_ext_dir/extensions.json" ]; then
      home_json="$ext_dir/extensions.json"
      tmp_json="$ext_dir/.extensions.json.$$"
      if [ -f "$home_json" ]; then
        @JQ@ -s 'add | unique_by(.identifier.id)' "$base_ext_dir/extensions.json" "$home_json" > "$tmp_json"
      else
        cp "$base_ext_dir/extensions.json" "$tmp_json"
      fi
      mv "$tmp_json" "$home_json"
    fi
    exec @VSCODE@ "$@" --extensions-dir "$ext_dir"
    EOF
        substituteInPlace "$out/bin/code" \
          --replace-fail @BASH@ ${pkgs.bash}/bin/bash \
          --replace-fail @BASE_EXT_DIR@ "$base_ext_dir" \
          --replace-fail @JQ@ ${pkgs.jq}/bin/jq \
          --replace-fail @NIX_BIN@ ${config.nix.package}/bin \
          --replace-fail @VSCODE@ ${vscodePackageRaw}/bin/code
        chmod +x "$out/bin/code"
  '';

  cosmicStartupApps = [
    {
      command = "${lib.getExe ghosttyNoPortal}";
      appId = "com.mitchellh.ghostty";
      workspace = "0";
      wait = 20;
    }
    {
      command = "${chromePackage}/bin/google-chrome-stable";
      appId = "google-chrome";
      workspace = "0";
      wait = 20;
    }
    {
      command = "${vscodePackage}/bin/code --new-window";
      appId = "Code";
      workspace = "0";
      wait = 20;
    }
    {
      command = "${discordPackage}/bin/discord";
      appId = "discord";
      workspace = "1";
      wait = 20;
      launchDelay = 8;
    }
    {
      command = "${pkgs.spotify}/bin/spotify";
      appId = "Spotify";
      workspace = "1";
      wait = 20;
      launchDelay = 3;
    }
    {
      command = "${pkgs.slack}/bin/slack";
      appId = "Slack";
      workspace = "1";
      wait = 20;
      launchDelay = 5;
    }
  ];

  cosmicStartupScript = pkgs.writeShellScript "cosmic-startup-apps" ''
    set -eu

    export PATH=${
      lib.makeBinPath [
        cosCli
        pkgs.bash
        pkgs.coreutils
        pkgs.git
        pkgs.go
        pkgs.templ
      ]
    }:$PATH

    ${lib.concatMapStringsSep "\n" (app: ''
      ${app.command} >/dev/null 2>&1 &
      sleep ${toString (app.launchDelay or 0)}
      cos-cli move --app-id ${lib.escapeShellArg app.appId} --workspace ${lib.escapeShellArg app.workspace} --wait ${toString (app.wait or 20)} >/dev/null 2>&1 || true
    '') cosmicStartupApps}
  '';
in

{
  imports = [
    # Selected by ./switch with: -I nixos-machine-config=./machines/<machine>.nix
    <nixos-machine-config>
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use ZFS-compatible LTS kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.supportedFilesystems = [ "zfs" ];

  # Machine identity lives in machines/<machine>.nix.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;

  # Keep the time zone synchronized with the machine's current location.
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable Wacom tablet/Cintiq metadata for COSMIC's libinput support.
  services.udev.packages = with pkgs; [
    libwacom
  ];

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Configure XKB for COSMIC and XWayland.
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "colemak";
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main.rightcontrol = "layer(rightcontrol)";
        "rightcontrol:C".right = "f24";
      };
    };
  };

  # Enable CUPS and Brother network printer support.
  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      brgenml1cupswrapper
      brgenml1lpr
      brlaser
      gutenprint
    ];
    webInterface = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.nats.enable = true;

  hardware.printers = {
    ensureDefaultPrinter = "Brother_MFC_L8900CDW";
    ensurePrinters = [
      {
        name = "Brother_MFC_L8900CDW";
        description = "Brother MFC-L8900CDW series";
        deviceUri = "dnssd://Brother%20MFC-L8900CDW%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-b42200d9be4a";
        model = "everywhere";
      }
    ];
  };

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.delaney = {
    isNormalUser = true;
    description = "Delaney";
    extraGroups = [
      "dialout"
      "input"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    (google-fonts.override {
      fonts = [
        "Audiowide"
        "Orbitron"
        "Oxanium"
      ];
    })
  ];

  environment.variables = {
    BROWSER = "${chromePackage}/bin/google-chrome-stable";
    SSH_ASKPASS_REQUIRE = "never";
    TERMINAL = "${lib.getExe ghosttyNoPortal}";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
    blender
    brotli
    bubblewrap
    bun
    clang
    cloc
    cmake
    compsize
    cosCli
    cosmicScreenshotSaveAndCopy
    (callPackage ./pkgs/codex.nix { })
    discordPackage
    gcc
    gh
    git
    tea
    gnumake
    go
    gopls
    ghosttyNoPortal
    chromePackage
    (callPackage ./pkgs/herdr.nix { })
    imagemagick
    impression
    inkscape
    jq
    krita
    libwacom
    llamaCppVulkan
    nats-server
    natscli
    ngrok
    nixfmt
    nodejs
    obs-studio
    openssl
    pciutils
    picotron
    piDev
    pulseaudio
    pv
    python3
    python313Packages.huggingface-hub
    ripgrep
    rtk
    slack
    spotify
    sqlite
    sqlitebrowser
    stableDiffusionCppVulkan
    stow
    system-config-printer
    templ
    terminalDictate
    terminalDictateToggle
    upx
    usbutils
    vlc
    vulkan-tools
    vscodePackage
    wl-clipboard
    wtype
    zoom-us
    zoomAwareBrowserDesktop
    zstd
    config.boot.zfs.package
  ];

  # COSMIC portal OpenURI currently returns success without opening Chrome.
  # Let xdg-open use mime defaults directly instead.
  xdg.portal.xdgOpenUsePortal = false;

  systemd.user.services.cosmic-startup-apps = lib.mkIf (cosmicStartupApps != [ ]) {
    description = "Launch and place apps on COSMIC workspaces";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${cosmicStartupScript}";
    };
  };

  system.activationScripts.rtkGlobalInit = {
    deps = [ "users" ];
    text = ''
      if [ -d /home/delaney ]; then
        install -d -m 0755 -o delaney -g users /home/delaney/.claude /home/delaney/.config
        ${lib.getExe' pkgs.util-linux "runuser"} -u delaney -- \
          env HOME=/home/delaney XDG_CONFIG_HOME=/home/delaney/.config \
          ${lib.getExe rtk} init -g --auto-patch
      fi
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
