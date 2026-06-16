# Original desktop/workstation hardware config.
# Generated hardware settings plus machine identity.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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
  boot.extraModulePackages = [ ];

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
