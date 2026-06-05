# NixOS Config

Machine-level NixOS configuration for this system lives here.

## Layout

- [configuration.nix](/home/delaney/nixos-config/configuration.nix:1): main system configuration
- [hardware-configuration.nix](/home/delaney/nixos-config/hardware-configuration.nix:1): hardware-generated settings
- [pkgs](/home/delaney/nixos-config/pkgs): custom packages used by the system config
- [switch](/home/delaney/nixos-config/switch:1): local wrapper for `nixos-rebuild switch` plus Stow dotfiles
- [dotfiles/nixos-home](/home/delaney/nixos-config/dotfiles/nixos-home): GNU Stow package linked into `$HOME`
- [apply-dotfiles](/home/delaney/nixos-config/apply-dotfiles:1): safe Stow wrapper with conflict backups

## Apply Config Changes

Use the local wrapper:

```bash
~/nixos-config/switch
```

Or, after dotfiles have been stowed, use the fish alias:

```bash
switch-nixos
```

The wrapper runs the rebuild, then restows user dotfiles:

```bash
sudo nixos-rebuild switch -I nixos-config=$HOME/nixos-config/configuration.nix
~/nixos-config/apply-dotfiles ~/nixos-config
```

If an existing target conflicts with a Stow-managed file, it is moved to `~/.dotfiles-backup/<timestamp>/` before linking.

## Validate Before Switching

Evaluate the full system config without applying it:

```bash
nix-instantiate '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=$HOME/nixos-config/configuration.nix
```

Build without switching:

```bash
sudo nixos-rebuild build -I nixos-config=$HOME/nixos-config/configuration.nix
```

Activate temporarily for testing:

```bash
sudo nixos-rebuild test -I nixos-config=$HOME/nixos-config/configuration.nix
```

## Update Packages

Most system packages follow the root `nixos` channel.

Update the channel, then rebuild:

```bash
sudo nix-channel --update
~/nixos-config/switch
```

Useful checks:

```bash
sudo nix-channel --list
nixos-version
```

## VS Code

VS Code is pinned separately from `nixos-unstable` inside [configuration.nix](/home/delaney/nixos-config/configuration.nix:9). That means:

- updating the main `nixos` channel does not update VS Code
- updating VS Code requires changing the pinned `unstablePkgs` tarball URL and `sha256`

Check the current pinned version:

```bash
nix-instantiate --eval --strict --expr 'let unstablePkgs = import (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/1c3fe55ad329cbcb28471bb30f05c9827f724c76.tar.gz"; sha256 = "1cb124rcycigz060wsix7a9bnyjdgwqns2fynkyfn20jgwxds6kg"; }) { config.allowUnfree = true; }; in unstablePkgs.vscode.version'
```

## COSMIC Session Behavior

This config also manages some session-level behavior:

- `PrintScreen` is rebound to a wrapper that saves screenshots to `~/Pictures/Screenshots` and copies the image to the Wayland clipboard
- startup apps are launched and moved onto COSMIC workspaces by the `cosmic-startup-apps` user service
- Ghostty, VS Code, COSMIC, fish, Git, SSH, MIME, Pi extension, and small Go tool shims are linked into `$HOME` via Stow after `switch`

If startup workspace placement changes, inspect the live session with:

```bash
cos-cli info --json
```
