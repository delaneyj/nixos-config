# NixOS Config

Machine-level NixOS configuration for this system lives here.

## Layout

- [configuration.nix](/home/delaney/nixos-config/configuration.nix:1): shared system configuration
- [machines](/home/delaney/nixos-config/machines): per-machine hardware-generated settings and machine identity
- [pkgs](/home/delaney/nixos-config/pkgs): custom packages used by the system config
- [switch](/home/delaney/nixos-config/switch:1): auto-detecting wrapper for `nixos-rebuild switch` plus Stow dotfiles
- [dotfiles/nixos-home](/home/delaney/nixos-config/dotfiles/nixos-home): GNU Stow package linked into `$HOME`, including local Pi agent skills under `.pi/agent/skills`
- [apply-dotfiles](/home/delaney/nixos-config/apply-dotfiles:1): safe Stow wrapper with conflict backups and Pi skill sync

## Apply Config Changes

Use the local wrapper:

```bash
~/nixos-config/switch
```

Or, after dotfiles have been stowed, use the fish alias:

```bash
switch-nixos
```

The wrapper auto-detects the machine, passes the matching `machines/<name>.nix` as `nixos-machine-config`, runs the rebuild, then restows user dotfiles:

```bash
sudo nixos-rebuild switch \
  -I nixos-config=$HOME/nixos-config/configuration.nix \
  -I nixos-machine-config=$HOME/nixos-config/machines/<name>.nix
~/nixos-config/apply-dotfiles ~/nixos-config
```

Override detection when needed:

```bash
NIXOS_MACHINE=yoga ~/nixos-config/switch
```

If an existing target conflicts with a Stow-managed file, it is moved to `~/.dotfiles-backup/<timestamp>/` before linking.

Before stowing, `apply-dotfiles` copies local Pi agent skills from `~/.pi/agent/skills` into `dotfiles/nixos-home/.pi/agent/skills`. After the first `switch`, those skill files are Stow-managed, so edits under `~/.pi/agent/skills` update this repo directly.

## Validate Before Switching

Evaluate the full system config without applying it:

```bash
nix-instantiate '<nixpkgs/nixos>' -A config.system.build.toplevel \
  -I nixos-config=$HOME/nixos-config/configuration.nix \
  -I nixos-machine-config=$HOME/nixos-config/machines/yoga.nix
```

Build without switching:

```bash
~/nixos-config/switch build
```

Activate temporarily for testing:

```bash
~/nixos-config/switch test
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

## Chrome and VS Code

Chrome and VS Code are pinned separately from the main `nixos` channel inside [configuration.nix](/home/delaney/nixos-config/configuration.nix:9). Chrome comes from the pinned `nixos-unstable` package set. VS Code uses an explicit upstream release override on that package set.

Updating the main `nixos` channel does not update either application. Update the `unstablePkgs` revision and hash for Chrome, and the explicit version, URL, and hash for VS Code.

Check the active versions after switching:

```bash
google-chrome-stable --version
code --version
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
