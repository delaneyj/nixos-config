# Lenovo Yoga 7 16IAH7 (DMI product_name: 82UF)
# Generated hardware settings plus machine identity.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Enable COSMIC Wacom workaround on this machine too.
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
