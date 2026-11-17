# Stream targets (do not paste keys into chat)

After `Install-MahObs.ps1`, open OBS → **Docks → Multiple output**.

Add three **Custom** targets:

## YouTube

- Server: `rtmp://a.rtmp.youtube.com/live2`
- Key: YouTube Studio → Go live → Stream

## Twitch

- Server: `rtmp://live.twitch.tv/app` (or regional ingest from dashboard)
- Key: Creator Dashboard → Settings → Stream

## Kick

- Server + key: Kick Creator Dashboard → Stream settings (often `rtmps://…`)

## Encode start point

- 1080p30, NVENC, ~6000 kbps, keyframe 2s, AAC 160k  
- Test one destination first, then enable all three and watch GPU + upload

## Primary Settings → Stream

You can leave Settings → Stream on one platform **or** unused; Multiple output can drive all three.
