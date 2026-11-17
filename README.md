# Mayank After Hours — OBS Suite (`mah-obs`)

Integrated **multistream + multichat docks + locked operator layout** for OBS 33, branded for **Mayank After Hours**.

This is **not** a full fork of OBS Studio’s C++ core (that would mean maintaining a private OBS forever).  
It **is** a real product repo that ships the same outcome the right way:

1. **Multistream** — vendored [obs-multi-rtmp](https://github.com/sorayuki/obs-multi-rtmp) (GPL) → YouTube + Twitch + Kick at once  
2. **Chat docks** — official platform popouts as OBS Custom Browser Docks (login cookies persist)  
3. **Loved layout preset** — your vertical chat column + operator chrome, restorable + lockable  
4. **One-click installer** — applies docks, layout, plugin, lock  

```
OBS 33 (stock)
 ├─ MAH Multistream dock   ← Multiple Output (plugin)
 ├─ Twitch / Kick / YouTube chat docks (tabs)
 ├─ MAH Multichat Help dock
 └─ Locked DockState preset (“loved” layout)
```

## Quick install (Windows)

1. Fully quit OBS (`File → Exit`)
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File D:\Codes\mah-obs\installer\Install-MahObs.ps1
```

3. Open OBS → enable docks under **Docks** if needed → **Lock Docks**
4. Open **Multiple output** dock → add YouTube / Twitch / Kick Custom RTMP targets  
   (**stream keys stay in OBS — never paste them into chat**)

## Why not fork all of OBS?

| Approach | Reality |
|---|---|
| Patch `Settings → Stream` for 3 keys in OBS core | Months of C++/Qt + every upstream release breaks you |
| Plugin multistream + Custom Browser Docks | Same user result, updates with stock OBS |
| This repo | Packages, brands, presets, installer, docs — shippable now |

Future: a native `mah-multichat` Qt dock plugin can live under `apps/` and replace browser docks. The architecture leaves that door open.

## Repo map

```
mah-obs/
  installer/          Install-MahObs.ps1 — plugin + docks + layout lock
  presets/            loved DockState / ExtraBrowserDocks
  docks/              MAH Multichat Help (local HTML)
  tools/              multi-rtmp Windows installer binary
  vendor/obs-multi-rtmp/   upstream GPL source (submodule-style vendor)
  docs/               architecture + stream target guide
  apps/multichat/     optional future merged-chat companion
```

## License

- This suite’s scripts/presets/docs: MIT (see `LICENSE`)
- `vendor/obs-multi-rtmp`: GPL-2.0 (upstream) — if you redistribute the plugin binary, comply with GPL

## Author

Mayank Raghuvanshi — Hinglish After Hours streams (YouTube / Twitch / Kick)
