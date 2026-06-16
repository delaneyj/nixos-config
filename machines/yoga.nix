# Lenovo Yoga 7 16IAH7 (DMI product_name: 82UF)
# Generated hardware settings plus machine identity.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "yoga";
  networking.hostId = "d518a0ef";

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/luks-8dbec096-24e7-4c6e-877e-1ba8e9e772ac";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-8dbec096-24e7-4c6e-877e-1ba8e9e772ac".device = "/dev/disk/by-uuid/8dbec096-24e7-4c6e-877e-1ba8e9e772ac";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/793B-609A";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
