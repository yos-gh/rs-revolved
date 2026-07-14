# Original SFX Runtime Masters

These seven files are lightly mastered runtime copies of the original Tonyu
WAV assets under `original/rs_tonyu_0.031/Usr/wav/`.

## Processing

- Preserve mono playback for clear game-event placement.
- Lower by 3 dB before filtering to prevent intermediate clipping.
- Remove only subsonic/DC energy below 18 Hz with a two-pole high-pass filter.
- Restore 2 dB, then catch filter overshoot at -1 dBFS without auto gain.
- Resample from 44.1 kHz to 48 kHz PCM16 using FFmpeg's high-quality converter.
- Do not denoise, brighten, stereo-widen, or alter the original envelopes.

Rebuild with `tools/master_original_sfx.ps1`.

## Original Playback Rules

- `shot`: every player-shot creation, random Tonyu volume 4-7.
- `bomb_s`: normal small-enemy death, normally volume 32-63.
- `bomb_s`: `zako3p` uses 16-47 and `zako4` uses 48-79.
- Legacy clipping workarounds are intentionally not reproduced: `zako7p`,
  `zako3p`, and `zako4` remain audible in every difficulty because the current
  runtime provides explicit polyphony limits and mastered headroom.
- `bomb_m`: `zakoM0`, `zakoM1`, boss turret, and boss-core death, volume 32-63.
- `die`: player death, volume 64-95.
- `extend`: score extend and boss-core reward, fixed volume 64.
- `gum_o`: Gum controller creation, volume 32-63.
- `gum_c`: guard-to-launch and return-to-relaunch transitions, volume 32-63.
  Cursor arrival, return start, and final storage are silent.
