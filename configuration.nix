# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  unstablePkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/1c3fe55ad329cbcb28471bb30f05c9827f724c76.tar.gz";
        sha256 = "1cb124rcycigz060wsix7a9bnyjdgwqns2fynkyfn20jgwxds6kg";
      })
      {
        config.allowUnfree = true;
      };
  handyFlake = builtins.getFlake "github:cjpais/Handy/a385371c32613c1ec2649a4f51522a7ddefb5d4c";
  cosmicScreenshotScript = pkgs.writeShellScript "cosmic-screenshot-save-and-copy" ''
    set -eu

    pictures_dir="$HOME/Pictures"
    marker="$(mktemp)"
    trap 'rm -f "$marker"' EXIT

    ${lib.getExe pkgs.cosmic-screenshot} --interactive=true --modal=true

    for _ in $(seq 1 20); do
      new_file="$(
        find "$pictures_dir" -maxdepth 2 -type f -name 'Screenshot_*.png' -newer "$marker" -print \
          | tail -n 1
      )"

      if [ -n "$new_file" ] && [ -f "$new_file" ]; then
        ${lib.getExe' pkgs.wl-clipboard "wl-copy"} --type image/png < "$new_file"
        exit 0
      fi

      sleep 0.1
    done
  '';

  cosmicSystemActions = pkgs.writeText "cosmic-system_actions" ''
    {
        /// Opens the application library
        AppLibrary: "cosmic-app-library",
        /// Decreases screen brightness
        BrightnessDown: "busctl --user call com.system76.CosmicSettingsDaemon /com/system76/CosmicSettingsDaemon com.system76.CosmicSettingsDaemon DecreaseDisplayBrightness",
        /// Increases screen brightness
        BrightnessUp: "busctl --user call com.system76.CosmicSettingsDaemon /com/system76/CosmicSettingsDaemon com.system76.CosmicSettingsDaemon IncreaseDisplayBrightness",
        /// Toggles display mode
        DisplayToggle: "cosmic-osd display",
        /// Switch between input sources
        InputSourceSwitch: "busctl --user call com.system76.CosmicSettingsDaemon /com/system76/CosmicSettingsDaemon com.system76.CosmicSettingsDaemon InputSourceSwitch",
        /// Opens the home folder in a system default file browser
        HomeFolder: "xdg-open ~",
        /// Logs out
        LogOut: "cosmic-osd log-out",
        /// Decreases keyboard brightness
        // KeyboardBrightnessDown,
        /// Increases keyboard brightness
        // KeyboardBrightnessUp,
        /// Opens the launcher
        Launcher: "cosmic-launcher",
        /// Locks the screen
        LockScreen: "loginctl lock-session",
        /// Mutes the active output device
        Mute: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        /// Mutes the active microphone
        MuteMic: "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
        /// Plays and Pauses audio
        PlayPause: "playerctl play-pause",
        /// Goes to the next track
        PlayNext: "playerctl next",
        /// Goes to the previous track
        PlayPrev: "playerctl previous",
        /// Power off handler
        PowerOff: "cosmic-osd shutdown",
        /// Takes a screenshot
        Screenshot: "${cosmicScreenshotScript}",
        /// Suspend the system
        Suspend: "systemctl suspend",
        /// Opens the system default terminal
        Terminal: "xdg-terminal-exec",
        /// Toggles touchpad on/off
        TouchpadToggle: "cosmic-osd touchpad",
        /// Lowers the volume of the active output device
        VolumeLower: "busctl --user call com.system76.CosmicSettingsDaemon /com/system76/CosmicSettingsDaemon com.system76.CosmicSettingsDaemon VolumeDown",
        /// Raises the volume of the active output device
        VolumeRaise: "busctl --user call com.system76.CosmicSettingsDaemon /com/system76/CosmicSettingsDaemon com.system76.CosmicSettingsDaemon VolumeUp",
        /// Opens the system default web browser
        WebBrowser: "xdg-open http://",
        /// Opens the (alt+tab) window switcher
        WindowSwitcher: "cosmic-launcher alt-tab",
        /// Opens the (alt+shift+tab) window switcher
        WindowSwitcherPrevious: "cosmic-launcher shift-alt-tab",
        /// Opens the workspace overview
        WorkspaceOverview: "cosmic-workspaces",
    }
  '';

  cosmicAutotileBehavior = pkgs.writeText "cosmic-autotile_behavior" ''
    Tiled
  '';

  cosmicCustomShortcuts = pkgs.writeText "cosmic-shortcuts-custom" ''
    {
        (modifiers: [], key: "F24"): System(PlayNext),
    }
  '';

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

      exec ${pkgs.google-chrome}/bin/google-chrome-stable "$@"
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

  cosmicWallpaper = ./Earth-behind-the-lunar-surface.jpg;

  cosmicBackgroundAll = pkgs.writeText "cosmic-background-all" ''
    (
        output: "all",
        source: Path("${cosmicWallpaper}"),
        filter_by_theme: true,
        rotation_frequency: 300,
        filter_method: Lanczos,
        scaling_mode: Zoom,
        sampling_method: Alphanumeric,
    )
  '';

  cosmicBackgroundSameOnAll = pkgs.writeText "cosmic-background-same-on-all" ''
    true
  '';

  cosmicWallpaperCustomImages = pkgs.writeText "cosmic-wallpaper-custom-images" ''
    [
        "${cosmicWallpaper}",
    ]
  '';

  ghosttyBellSound = pkgs.runCommand "ghostty-bell.wav" { nativeBuildInputs = [ pkgs.python3 ]; } ''
        python3 -c '
    import math, os, struct, wave

    sample_rate = 44100
    samples = int(sample_rate * 0.18)
    with wave.open(os.environ["out"], "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        frames = bytearray()
        for i in range(samples):
            value = int(22000 * math.sin(2 * math.pi * 880 * i / sample_rate))
            frames.extend(struct.pack("<h", value))
        wav.writeframes(frames)
    '
  '';

  ghosttyConfig = pkgs.writeText "ghostty-config" ''
    theme = Gruvbox Dark
    bell-features = audio
    bell-audio-path = ${ghosttyBellSound}
    bell-audio-volume = 1.0
  '';

  piBellOnDoneExtension = pkgs.writeText "bell-on-done.ts" ''
    import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
    import { spawn } from "node:child_process";

    export default function (pi: ExtensionAPI) {
      pi.on("agent_end", async () => {
        spawn("${lib.getExe' pkgs.pulseaudio "paplay"}", ["${ghosttyBellSound}"], {
          detached: true,
          stdio: "ignore",
        }).unref();
      });
    }
  '';

  cosCli = pkgs.callPackage ./pkgs/cos-cli.nix { };
  piDev = unstablePkgs.callPackage ./pkgs/pi-dev { };
  rtk = pkgs.callPackage ./pkgs/rtk.nix { };
  llamaCppVulkan = unstablePkgs.llama-cpp.override {
    vulkanSupport = true;
  };
  stableDiffusionCppVulkan = unstablePkgs.stable-diffusion-cpp-vulkan;
  vscodePackageBase = unstablePkgs.vscode-with-extensions.override {
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
        version = "0.141.2026042904";
        sha256 = "HYJt2E2z64SyZsNrmK8t8npewz3YTfr011sUe5lHLYg=";
      }
      {
        name = "copilot-chat";
        publisher = "GitHub";
        version = "0.44.2";
        sha256 = "18lpapr3n0kpgrvg20kp8bgg4srmicw11cnf5fwdclmk1rnfjclj";
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
          --replace-fail @VSCODE@ ${unstablePkgs.vscode}/bin/code
        chmod +x "$out/bin/code"
  '';

  vscodeSettings = pkgs.writeText "vscode-settings.json" ''
    {
      "workbench.colorTheme": "Gruvbox Dark Hard",
      "editor.fontFamily": "'Fira Code', monospace",
      "editor.fontLigatures": true,
      "editor.formatOnSave": true,
      "extensions.autoCheckUpdates": false,
      "extensions.autoUpdate": false,
      "git.confirmSync": false,
      "git.path": "${pkgs.git}/bin/git",
      "go.alternateTools": {
        "go": "${pkgs.go}/bin/go"
      },
      "go.goroot": "${pkgs.go}/share/go",
      "templ.executablePath": "${pkgs.templ}/bin/templ",
      "json.schemaDownload.trustedDomains": {
        "https://schemastore.azurewebsites.net/": true,
        "https://raw.githubusercontent.com/microsoft/vscode/": true,
        "https://raw.githubusercontent.com/devcontainers/spec/": true,
        "https://www.schemastore.org/": true,
        "https://json.schemastore.org/": true,
        "https://json-schema.org/": true,
        "https://developer.microsoft.com/json-schemas/": true,
        "https://biomejs.dev": true
      },
      "terminal.integrated.defaultProfile.linux": "fish",
      "terminal.integrated.profiles.linux": {
        "fish": {
          "path": "${pkgs.fish}/bin/fish"
        }
      },
      "update.mode": "none"
    }
  '';

  cosmicStartupApps = [
    {
      command = "${pkgs.ghostty}/bin/ghostty";
      appId = "com.mitchellh.ghostty";
      workspace = "0";
      wait = 20;
    }
    {
      command = "${pkgs.google-chrome}/bin/google-chrome-stable";
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
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    handyFlake.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use ZFS-compatible LTS kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "nixos"; # Define your hostname.
  networking.hostId = "aa44369d"; # Required for ZFS pool imports.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

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

  # Keep X11 available for apps that still need it.
  services.xserver.enable = true;

  # Enable the COSMIC greeter and desktop session.
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
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
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -l gcr_sock "/run/user/"(id -u)"/gcr/ssh"

      if test -S $gcr_sock
        if not set -q SSH_AUTH_SOCK; or not test -S "$SSH_AUTH_SOCK"
          set -gx SSH_AUTH_SOCK $gcr_sock
        end
      end

      if set -q SSH_AUTH_SOCK; and test -S "$SSH_AUTH_SOCK"
        set -l ssh_bootstrap_flag "$XDG_RUNTIME_DIR/fish-ssh-agent-bootstrapped"

        if not test -e $ssh_bootstrap_flag
          if test -f ~/.ssh/id_rsa
            ssh-add -l >/dev/null 2>&1
            if test $status -eq 2
              ssh-add ~/.ssh/id_rsa </dev/tty >/dev/tty 2>/dev/null
            end
          end

          touch $ssh_bootstrap_flag
        end
      end
    '';
  };
  programs.git = {
    enable = true;
    config = {
      credential.helper = "cache --timeout=31536000";
      init.defaultBranch = "main";
      pull.rebase = false;
      user = {
        name = "Delaney Gillilan";
        email = "delaneygillilan@gmail.com";
      };
    };
  };
  programs.ssh = {
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_rsa
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.handy.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];

  environment.shellAliases = {
    sd = "sd-cli";
    switch-nixos = "$HOME/nixos-config/switch";
    yolo = "codex --dangerously-bypass-approvals-and-sandbox";
  };

  environment.variables = {
    BROWSER = "${pkgs.google-chrome}/bin/google-chrome-stable";
    SSH_ASKPASS_REQUIRE = "never";
    TERMINAL = "ghostty";
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
    (callPackage ./pkgs/codex.nix { })
    discordPackage
    gcc
    gh
    git
    gnumake
    go
    ghostty
    google-chrome
    imagemagick
    impression
    jq
    krita
    llamaCppVulkan
    nats-server
    natscli
    ngrok
    nixfmt
    nodejs
    pciutils
    piDev
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
    system-config-printer
    templ
    vulkan-tools
    vscodePackage
    wl-clipboard
    wtype
    zoom-us
    zoomAwareBrowserDesktop
    zstd
    config.boot.zfs.package
  ];

  xdg = {
    terminal-exec = {
      enable = true;
      settings = {
        COSMIC = [ "com.mitchellh.ghostty.desktop" ];
        default = [ "com.mitchellh.ghostty.desktop" ];
      };
    };

    mime = {
      defaultApplications = {
        "text/html" = "zoom-aware-browser.desktop";
        "x-scheme-handler/http" = "zoom-aware-browser.desktop";
        "x-scheme-handler/https" = "zoom-aware-browser.desktop";
        "x-scheme-handler/zoommtg" = "Zoom.desktop";
        "x-scheme-handler/zoomus" = "Zoom.desktop";
      };
    };

    # COSMIC portal OpenURI currently returns success without opening Chrome.
    # Let xdg-open use mime defaults directly instead.
    portal.xdgOpenUsePortal = false;
  };

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

  system.activationScripts.cosmicUserDefaults.text = ''
    install -d -m 0755 /home/delaney/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1
    ln -sfn ${cosmicSystemActions} /home/delaney/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions
    ln -sfn ${cosmicCustomShortcuts} /home/delaney/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
    chown -h delaney:users /home/delaney/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions
    chown -h delaney:users /home/delaney/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom

    install -d -m 0755 /home/delaney/.config/cosmic/com.system76.CosmicComp/v1
    ln -sfn ${cosmicAutotileBehavior} /home/delaney/.config/cosmic/com.system76.CosmicComp/v1/autotile_behavior
    chown -h delaney:users /home/delaney/.config/cosmic/com.system76.CosmicComp/v1/autotile_behavior

    install -d -m 0755 /home/delaney/.config/cosmic/com.system76.CosmicBackground/v1
    ln -sfn ${cosmicBackgroundAll} /home/delaney/.config/cosmic/com.system76.CosmicBackground/v1/all
    ln -sfn ${cosmicBackgroundSameOnAll} /home/delaney/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all
    chown -h delaney:users /home/delaney/.config/cosmic/com.system76.CosmicBackground/v1/all
    chown -h delaney:users /home/delaney/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all

    install -d -m 0755 /home/delaney/.config/cosmic/com.system76.CosmicSettings.Wallpaper/v1
    ln -sfn ${cosmicWallpaperCustomImages} /home/delaney/.config/cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images
    chown -h delaney:users /home/delaney/.config/cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images

    install -d -m 0755 /home/delaney/.config/ghostty
    rm -f /home/delaney/.config/ghostty/config
    ln -sfn ${ghosttyConfig} /home/delaney/.config/ghostty/config
    chown -h delaney:users /home/delaney/.config/ghostty/config

    install -d -m 0755 /home/delaney/.pi/agent/extensions
    rm -f /home/delaney/.pi/agent/extensions/bell-on-done.ts
    ln -sfn ${piBellOnDoneExtension} /home/delaney/.pi/agent/extensions/bell-on-done.ts
    chown -h delaney:users /home/delaney/.pi/agent/extensions/bell-on-done.ts

    install -d -m 0755 /home/delaney/.config/Code/User
    rm -f /home/delaney/.config/Code/User/settings.json
    ln -sfn ${vscodeSettings} /home/delaney/.config/Code/User/settings.json
    chown -h delaney:users /home/delaney/.config/Code/User/settings.json

    install -d -m 0755 -o delaney -g users /home/delaney/go/bin
    ln -sfn ${pkgs.templ}/bin/templ /home/delaney/go/bin/templ
    chown -h delaney:users /home/delaney/go/bin/templ

    if [ -d /home/delaney/.config/Code/Backups ]; then
      find /home/delaney/.config/Code/Backups -path '*/vscode-userdata/*' -type f | while read -r backup; do
        if head -n 1 "$backup" | grep -Fq 'vscode-userdata:/home/delaney/.config/Code/User/settings.json '; then
          rm -f "$backup"
        fi
      done
    fi
  '';

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
