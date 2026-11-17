# Architecture

## Goal

Operator laptop runs OBS with:

- one encode (1080p NVENC)
- three publish targets (YouTube, Twitch, Kick)
- vertical chat docks (tab switcher)
- locked layout that survives relaunch

## Decision: suite + plugin, not OBS Studio core fork

Forking [obsproject/obs-studio](https://github.com/obsproject/obs-studio) to put three stream keys into `Settings → Stream` means owning a private OBS build forever. Upstream moves fast; every release becomes a merge tax.

Instead `mah-obs` integrates:

| Layer | Tech | Role |
|---|---|---|
| Multistream | `vendor/obs-multi-rtmp` (GPL) | Multiple Output dock |
| Chat | OBS Custom Browser Docks | Official Twitch/Kick/YouTube pages |
| Layout | `presets/layout-loved.json` | DockState + ExtraBrowserDocks + SideDocks |
| Installer | `installer/Install-MahObs.ps1` | One-shot apply |

## Multichat truth

Official platform pages **cannot** be iframe-merged (`ERR_BLOCKED_BY_RESPONSE`).  
So MAH uses **tabbed top-level docks** (what you already love).

Merged “read all / send all” needs either:

- a future native Qt dock plugin under `apps/`, or
- a companion chat aggregator (out of scope for v1)

Kick’s official OBS popout remains **read-only** per Kick’s docs.

## Future native plugin path

```
apps/
  mah-multistream/   # optional rebranded fork of multi-rtmp
  mah-multichat/     # Qt dock: Twitch IRC + YT API + Kick WS
```

v1 ships the installer suite so streaming works **tonight**. Native plugins evolve in-tree without blocking go-live.
