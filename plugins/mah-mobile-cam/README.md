# MAH Mobile Camera (OBS plugin)

Standalone OBS module — no fork. Phone browser → LAN WebSocket MJPEG into an **MAH Mobile Camera** source.

Full wire format: [docs/PROTOCOL.md](../../docs/PROTOCOL.md).

## Build (Windows x64, like obs-multi-rtmp)

From this directory:

```powershell
cmake --preset windows-x64
cmake --build build_x64 --config RelWithDebInfo
```

Or classic configure:

```powershell
cmake -S . -B build_x64 -G "Visual Studio 17 2022" -A x64
cmake --build build_x64 --config RelWithDebInfo
```

Output (plugin template layout):

- `build_x64/rundir/RelWithDebInfo/mah-mobile-cam.dll`
- `build_x64/rundir/RelWithDebInfo/mah-mobile-cam/data/` (locale + web UI)

Copy those into stock OBS, or stage under `release/` or `dist/` and run [Install-MahObs.ps1](../../installer/Install-MahObs.ps1).

### Optional H.264

Default build is **MJPEG only** (web path). Native TCP H.264 needs FFmpeg:

```powershell
cmake -S . -B build_x64 -DENABLE_FFMPEG=ON ...
```

## Phone flow (optimistic)

1. Install **stock OBS 33+** and this plugin (MAH suite installer or manual copy).
2. In OBS, add source **MAH Mobile Camera**.
3. On the source properties, copy **Phone URL** (`http://<LAN-IP>:28889/?p=<pairing>`).
4. On the phone (same Wi‑Fi or USB tether), open the URL in Safari/Chrome → **Allow camera & start**.
5. Keep the tab open; frames appear in the source. Mic optional per protocol.

Native Android/iOS companions use the same MAH1 protocol on TCP port `28887` — see PROTOCOL.md.