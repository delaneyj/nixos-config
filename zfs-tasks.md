# ZFS Stardust Test Tasks

Goal: shrink current ext4 `/` as needed, create a 1 TiB ZFS partition, enable `zstd` compression + `recordsize=256K`, copy the MusicBrainz Stardust DB, and inspect compression/space stats.

## Current state

- Disk: `/dev/nvme0n1`, ~1.9T
- `/boot`: `/dev/nvme0n1p1`, vfat, 1G
- `/`: `/dev/nvme0n1p2`, ext4, ~1.9T
- `/` usage at start: ~192G used, ~1.6T free
- Recheck before switch/build:
  - Runtime kernel: `6.19.0`
  - Runtime ZFS tools: not yet on `PATH`
  - Current partition table still only `p1` + `p2`; no `p3` yet
  - Built ZFS-capable NixOS closure: `/nix/store/403as4v7asyqyxlz0zi7dl9dqirkn9c1-nixos-system-nixos-25.11.6074.fa56d7d6de78`
- MusicBrainz DB:
  - `/home/delaney/repos/stardust/data/musicbrainz/stardust/19910101-19911231.db`
  - apparent size: 458M
  - disk usage: 454M

## Progress

- [x] Confirmed current disk layout and free space
- [x] Found MusicBrainz Stardust DB
- [x] Added NixOS ZFS support in `configuration.nix`
  - `boot.kernelPackages = pkgs.linuxPackages_6_12;`
  - `boot.supportedFilesystems = [ "zfs" ];`
  - `networking.hostId = "aa44369d";`
  - `services.zfs.autoScrub.enable = true;`
  - `services.zfs.trim.enable = true;`
  - `config.boot.zfs.package` in `environment.systemPackages`
- [x] Verified eval/dry-build uses kernel `6.12.70` and ZFS `2.3.5`
- [x] Built system closure with kernel `6.12.70` and ZFS userspace `2.3.5`
- [x] Retried `./switch` from agent; blocked by sudo requiring a real terminal/password prompt
- [ ] User runs `./switch` manually; agent must not run it
- [ ] Reboot into kernel `6.12.70`
- [ ] Boot live USB / rescue environment
- [ ] Shrink `/dev/nvme0n1p2` ext4 to ~883 GiB
- [ ] Create `/dev/nvme0n1p3` as ~1 TiB ZFS partition
- [ ] Boot installed NixOS again
- [ ] Create ZFS pool on part3
- [ ] Create dataset with `compression=zstd`, `recordsize=256K`
- [ ] Copy MusicBrainz DB onto ZFS dataset
- [ ] Collect ZFS compression/usage stats

## Step 1: apply ZFS-capable NixOS config

From `/home/delaney/nixos-config`:

```bash
# Already built successfully; this only prefetches/builds and updates ./result.
nixos-rebuild build -I nixos-config=$PWD/configuration.nix

# Manual-only: user runs this. Agent must not run switch.
./switch
reboot
```

After reboot:

```bash
uname -r
command -v zpool
command -v zfs
```

Expected kernel: `6.12.70`.

Current blocker: non-interactive `sudo` is unavailable from the agent:

```text
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
```

Agent instruction: do not run `./switch`; ask the user to run it locally in a terminal, enter password, then reboot.

## Step 2: shrink `/` offline to make ZFS 1 TiB

Do this from a live USB/rescue environment. Do not shrink mounted `/`.

Preferred: use GParted.

- Select `/dev/nvme0n1`
- Leave `/dev/nvme0n1p1` unchanged
- Shrink `/dev/nvme0n1p2` to roughly `883 GiB`
- Create `/dev/nvme0n1p3` at the end of the disk with size `1024 GiB`

CLI equivalent from live USB:

```bash
sudo e2fsck -f /dev/nvme0n1p2

# Shrink filesystem below the final partition size first.
# Final p2 will be ~882.7 GiB, so 880G leaves margin.
sudo resize2fs /dev/nvme0n1p2 880G

# Disk has 4000797360 512B sectors.
# Make p3 start on a 1 MiB boundary and occupy just over 1 TiB:
#   p3 start: 1853313024s
#   p3 end:   100%
#   p2 end:   1853313023s
sudo parted /dev/nvme0n1 --script unit s resizepart 2 1853313023s
sudo parted /dev/nvme0n1 --script unit s mkpart zfs 1853313024s 100%
sudo parted /dev/nvme0n1 --script name 3 zfs

sudo partprobe /dev/nvme0n1
sudo e2fsck -f /dev/nvme0n1p2

# Grow ext4 to exactly fill the resized p2.
sudo resize2fs /dev/nvme0n1p2
```

Expected after shrink:

- `/dev/nvme0n1p2`: ~882.7 GiB ext4 root
- `/dev/nvme0n1p3`: ~1024 GiB / 1 TiB for ZFS

## Step 3: create ZFS pool and dataset

Back in installed NixOS:

```bash
ls -l /dev/disk/by-id/*part3
```

Pick the stable by-id path for part3, then:

```bash
DISK=/dev/disk/by-id/YOUR_NVME_PART3

sudo zpool create -f \
  -o ashift=12 \
  -O mountpoint=none \
  zstardust "$DISK"

sudo zfs create \
  -o mountpoint=/zfs/stardust \
  -o recordsize=256K \
  -o compression=zstd \
  -o atime=off \
  zstardust/db

sudo chown delaney:users /zfs/stardust
```

Verify properties:

```bash
zfs get recordsize,compression,compressratio,used,logicalused zstardust/db
zpool status zstardust
```

## Step 4: copy MusicBrainz DB and inspect stats

```bash
SRC=/home/delaney/repos/stardust/data/musicbrainz/stardust/19910101-19911231.db
DST=/zfs/stardust/stardust.db

cp "$SRC" "$DST"
sync

ls -lh "$SRC" "$DST"
du -h "$SRC" "$DST"
zfs get recordsize,compression,compressratio,used,logicalused,refer,logicalrefer zstardust/db
```

Optional deeper stats:

```bash
zpool list zstardust
zfs list -o name,used,avail,refer,compressratio,logicalused,logicalrefer zstardust/db
```

## Immediate next steps

1. User: run in a local terminal:

   ```bash
   cd /home/delaney/nixos-config
   ./switch
   reboot
   ```

2. After reboot, verify ZFS-capable system:

   ```bash
   uname -r
   command -v zpool
   command -v zfs
   zfs --version
   ```

   Expected: kernel `6.12.70`, ZFS `2.3.5`.

3. Boot live USB/rescue environment and shrink `/dev/nvme0n1p2` offline. Prefer GParted. If using CLI, run the commands in Step 2 exactly.

4. Boot installed NixOS again and confirm `p3` exists:

   ```bash
   lsblk -o NAME,SIZE,FSTYPE,FSUSE%,MOUNTPOINTS /dev/nvme0n1
   ls -l /dev/disk/by-id/*part3
   ```

5. Create pool/dataset and copy DB using Step 3 + Step 4.

## Notes

- ZFS compression applies to newly written data only. Set `compression=zstd` and `recordsize=256K` before copying the DB.
- `recordsize=256K` is per-dataset, not per-file after the fact.
- Use `/dev/disk/by-id/...part3` for pool creation, not `/dev/nvme0n1p3`, to avoid import/device-name surprises.
- ZFS with a single disk gives checksums/compression/snapshots, but no self-healing redundancy.
