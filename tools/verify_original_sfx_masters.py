from __future__ import annotations

import math
import struct
import wave
from pathlib import Path


EVENTS = ("shot", "bomb_s", "bomb_m", "die", "extend", "gum_o", "gum_c")
SOURCE = Path("original/rs_tonyu_0.031/Usr/wav")
RUNTIME = Path("assets/audio/runtime/original_mastered")


def read(path: Path) -> tuple[wave._wave_params, tuple[int, ...]]:
    with wave.open(str(path), "rb") as audio:
        params = audio.getparams()
        values = struct.unpack(f"<{params.nframes}h", audio.readframes(params.nframes))
    return params, values


def main() -> None:
    for event in EVENTS:
        source_params, _ = read(SOURCE / f"{event}.wav")
        runtime_params, values = read(RUNTIME / f"{event}.wav")
        assert runtime_params.nchannels == 1, f"{event}: expected mono"
        assert runtime_params.sampwidth == 2, f"{event}: expected PCM16"
        assert runtime_params.framerate == 48_000, f"{event}: expected 48 kHz"
        source_duration = source_params.nframes / source_params.framerate
        runtime_duration = runtime_params.nframes / runtime_params.framerate
        assert abs(source_duration - runtime_duration) < 0.0001, f"{event}: duration drift"
        peak = max(abs(value) for value in values) / 32768.0
        rms = math.sqrt(sum(value * value for value in values) / len(values)) / 32768.0
        assert 0.10 < peak <= 0.90, f"{event}: unexpected peak {peak:.3f}"
        print(f"{event:7} {runtime_duration:5.3f}s peak={peak:.3f} rms={rms:.3f}")
    print(f"verified {len(EVENTS)} original SFX runtime masters")


if __name__ == "__main__":
    main()
