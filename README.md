# nixos-laptop

Flake-based NixOS configuration for my personal laptop. Uses [niri](https://github.com/YaLTeR/niri) as the Wayland compositor and [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) as the status bar/shell.

## System Overview

| Property       | Value                        |
|----------------|------------------------------|
| Hostname       | `nixos-laptop`               |
| Architecture   | `x86_64-linux`               |
| NixOS channel  | `nixos-unstable`             |
| Compositor     | niri (Wayland)               |
| Display manager| greetd → niri-session        |
| Shell          | noctalia-shell               |
| GPU            | AMD (amdgpu + ROCm)          |
| Audio          | PipeWire                     |
| Timezone       | America/Edmonton             |
| Locale         | en_CA.UTF-8                  |

## Flake Inputs

| Input     | Source                                      |
|-----------|---------------------------------------------|
| nixpkgs   | `github:nixos/nixpkgs/nixos-unstable`       |
| noctalia  | `github:noctalia-dev/noctalia-shell`        |

## Features

### Desktop
- **niri** — scrollable-tiling Wayland compositor, launched via greetd
- **Noctalia Shell** — status bar/shell layer, depends on upower for battery info
- **fuzzel** — app launcher
- **swaybg** — wallpaper setter (used by Noctalia)
- **wlsunset** — night-light / blue-light filter
- **alacritty** — terminal emulator
- Full GTK/dconf integration with adw-gtk3 theme and Capitaine cursors

### Hardware
- AMD GPU with 32-bit support and ROCm ICD for compute
- PipeWire audio with ALSA and PulseAudio compatibility layers
- Bluetooth enabled
- Touchscreen disabled via udev rule (ELAN901C)

### Power Management
- **TLP** — aggressive power saving on battery, full performance on AC
  - CPU boost disabled on battery, enabled on AC
  - Runtime PM set to `auto` on battery
  - USB autosuspend enabled
- **auto-cpufreq** — governor switching (powersave on battery, performance on AC)
- `power-profiles-daemon` disabled (conflicts with TLP)

### Networking
- NetworkManager + wpa_supplicant (wireless)
- **Tailscale** VPN — `tailscale0` interface is fully trusted in the firewall
- **KDE Connect** ports open (TCP/UDP 1714–1764)
- NAS automount over SMB/CIFS via Tailscale (`//100.77.111.96/Public` → `/mnt/nas`)
  - Credentials stored in `/etc/nixos/smb-secrets`
  - Lazy-mounted, 60s idle timeout

### Flatpak
- Flatpak enabled system-wide (add Flathub separately after install)

### Nix Settings
- Flakes and `nix-command` enabled
- Store auto-optimisation on
- Weekly garbage collection, purging generations older than 7 days

## Installed Packages

| Category    | Packages                                                                 |
|-------------|--------------------------------------------------------------------------|
| Core        | vim, neovim, wget, git, alacritty, noctalia-shell, claude-code          |
| Toolkit     | vlc, btop, rsync, fastfetch, bash-completion, openssh, unzip, libreoffice-fresh |
| Launcher    | fuzzel                                                                   |
| Wayland     | swaybg, wlsunset                                                         |
| Appearance  | capitaine-cursors, adw-gtk3                                              |
| Fonts       | Inter, Noto (+ CJK + emoji), JetBrains Mono, Meslo LG (Nerd), Fira Code, Libre Baskerville, Cantarell, Liberation TTF |

## Applying the Configuration

**First time (on a fresh NixOS install):**

```bash
# Clone the repo
git clone https://github.com/Khizar-design/nixos-files.git ~/nixos

# Link or copy to /etc/nixos (or point nixos-rebuild at the flake directly)
sudo nixos-rebuild switch --flake ~/nixos#nixos-laptop
```

**After making changes:**

```bash
sudo nixos-rebuild switch --flake ~/nixos#nixos-laptop
```

**Test a change without committing it to the boot entry:**

```bash
sudo nixos-rebuild test --flake ~/nixos#nixos-laptop
```

## NAS Credentials

The SMB mount expects a credentials file at `/etc/nixos/smb-secrets` (not tracked in git):

```
username=YOUR_NAS_USER
password=YOUR_NAS_PASSWORD
```

Set permissions so only root can read it:

```bash
sudo chmod 600 /etc/nixos/smb-secrets
```

## Reloading niri Config

Niri uses live-reload, so once you save your files, it will take effect. You can verify your files integrity with

```
bash

niri validate
```
