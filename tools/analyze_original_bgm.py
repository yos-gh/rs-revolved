#!/usr/bin/env python3
"""Audit the original Ogg loops using only FFmpeg and the Python stdlib."""

from __future__ import annotations

import array
import json
import math
import pathlib
import subprocess


ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "original" / "rs_tonyu_0.031" / "Ogg"
SAMPLE_RATE = 12_000
WINDOW = 256


def decode_mono(path: pathlib.Path) -> array.array:
    command = [
        "ffmpeg", "-v", "error", "-i", str(path), "-ac", "1", "-ar",
        str(SAMPLE_RATE), "-f", "f32le", "-",
    ]
    samples = array.array("f")
    samples.frombytes(subprocess.check_output(command))
    return samples


def probe(path: pathlib.Path) -> dict:
    command = [
        "ffprobe", "-v", "error", "-show_entries",
        "format=duration,bit_rate:stream=sample_rate,channels", "-of", "json",
        str(path),
    ]
    return json.loads(subprocess.check_output(command, text=True))


def rms(values) -> float:
    return math.sqrt(sum(value * value for value in values) / max(1, len(values)))


def estimate_bpm(samples: array.array) -> tuple[float, float]:
    envelope = []
    for start in range(0, len(samples) - WINDOW, WINDOW):
        envelope.append(rms(samples[start:start + WINDOW]))
    onset = [max(0.0, envelope[i] - envelope[i - 1]) for i in range(1, len(envelope))]
    mean = sum(onset) / max(1, len(onset))
    onset = [value - mean for value in onset]
    rate = SAMPLE_RATE / WINDOW
    best = (0.0, 0)
    scores = []
    for bpm in range(70, 191):
        lag = max(1, round(rate * 60.0 / bpm))
        score = sum(onset[i] * onset[i - lag] for i in range(lag, len(onset)))
        scores.append(score)
        if score > best[0]:
            best = (score, bpm)
    sorted_scores = sorted(scores, reverse=True)
    confidence = best[0] / max(1e-12, sorted_scores[1] if len(sorted_scores) > 1 else best[0])
    return float(best[1]), confidence


def audit(path: pathlib.Path) -> dict:
    metadata = probe(path)
    samples = decode_mono(path)
    bpm, confidence = estimate_bpm(samples)
    edge = min(len(samples) // 4, SAMPLE_RATE // 4)
    seam_delta = rms([samples[i] - samples[-edge + i] for i in range(edge)])
    crossings = sum(
        1 for left, right in zip(samples, samples[1:])
        if (left < 0.0 <= right) or (right < 0.0 <= left)
    )
    return {
        "file": path.name,
        "duration_seconds": round(float(metadata["format"]["duration"]), 3),
        "sample_rate": int(metadata["streams"][0]["sample_rate"]),
        "channels": int(metadata["streams"][0]["channels"]),
        "estimated_bpm": bpm,
        "tempo_confidence_ratio": round(confidence, 3),
        "rms_dbfs": round(20.0 * math.log10(max(1e-12, rms(samples))), 2),
        "zero_crossings_per_second": round(crossings / (len(samples) / SAMPLE_RATE), 1),
        "edge_difference_rms": round(seam_delta, 6),
    }


def main() -> None:
    results = [audit(SOURCE_DIR / f"{index}.ogg") for index in range(1, 5)]
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
