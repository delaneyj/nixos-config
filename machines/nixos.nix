# Original desktop/workstation hardware config.
# Generated hardware settings plus machine identity.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Enable COSMIC Wacom workaround on this machine only.
  nixpkgs.overlays = [
    (_final: prev: {
      cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            name = "2287.patch";
            url = "https://github.com/pop-os/cosmic-comp/commit/079fcb4703f429a7211b1524c22db8645aef44b0.patch";
            hash = "sha256-H/+UIIooz6bRMmDiPp+Qp5f61V5+062e8Y5lWmU5g0I=";
          })
        ];
      });
    })
  ];

  networking.hostName = "nixos";
  networking.hostId = "aa44369d";

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    # Keep the Cintiq Pro 24 USB hub/tablet path from dropping during enumeration.
    "usbcore.autosuspend=-1"
    "usbcore.quirks=056a:037f:k,056a:037c:k,056a:0351:k,056a:0355:k,056a:0331:k"
  ];
  boot.extraModulePackages = [ ];

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="056a", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="056a", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="056a", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/83613c87-fd02-4b71-b6d3-3deb0b0debf4";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0785-8C2A";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/df8b8504-75f2-425c-a5fa-87e018df8874";
    fsType = "btrfs";
    options = [
      "compress-force=zstd:3"
      "noatime"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
