# ThinkPad E14 Gen 3 hardware config (migrated from prior shared desktop/workstation settings).
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

  networking.hostName = "thinkpad";
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
    device = "/dev/disk/by-uuid/db5c5a90-32e8-477e-8f3a-3e2b2000603f";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B56F-154A";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # ThinkPad-specific: skip auto-starting COSMIC apps.
  systemd.user.services.cosmic-startup-apps.enable = false;

  # Keep COSMIC Wacom workaround overlay off on ThinkPad.
  nixpkgs.overlays = lib.mkForce [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
