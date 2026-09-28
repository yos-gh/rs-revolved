class_name BgmPlayer
extends Node

const TimeWarpAudioUtil := preload("res://scripts/core/time_warp_audio.gd")

const TRACKS := {
	1: preload("res://assets/audio/runtime/original_bgm/1.ogg"),
	2: preload("res://assets/audio/runtime/original_bgm/2.ogg"),
	3: preload("res://assets/audio/runtime/original_bgm/3.ogg"),
	4: preload("res://assets/audio/runtime/original_bgm/4.ogg"),
}

# Every loop is a whole number of bars with its first beat at the start of the file.
const TRACK_BPM := {
	1: 165.0,
	2: 165.0,
	3: 165.0,
	4: 120.0,
}

const PLAYBACK_VOLUME_DB := -10.0

var current_track := 0
var player: AudioStreamPlayer
var _loop_streams := {}


func setup() -> void:
	TimeWarpAudioUtil.ensure_bus()
	player = AudioStreamPlayer.new()
	player.name = "OriginalBgm"
	if OS.has_feature("web"):
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	player.volume_db = PLAYBACK_VOLUME_DB
	player.bus = TimeWarpAudioUtil.BUS_NAME
	add_child(player)
	for track in TRACKS:
		var stream := TRACKS[track].duplicate() as AudioStreamOggVorbis
		stream.loop = true
		_loop_streams[track] = stream


func sync(game_mode: String, endless_difficulty: int, music_stage: int) -> void:
	var target := track_for_state(game_mode, endless_difficulty, music_stage)
	if target == current_track:
		return
	play_track(target)


func play_track(track: int) -> void:
	if not _loop_streams.has(track):
		stop()
		return
	current_track = track
	player.stream = _loop_streams[track]
	player.play()


func stop() -> void:
	current_track = 0
	if player != null:
		player.stop()
		player.stream = null


func beat_seconds() -> float:
	return 60.0 / float(TRACK_BPM.get(current_track, 120.0))


# Audible playback position in beats, or -1.0 when nothing is playing.
func beat_position() -> float:
	if current_track == 0 or player == null or not player.playing:
		return -1.0
	var seconds := player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	return maxf(0.0, seconds) / beat_seconds()


static func track_for_state(game_mode: String, endless_difficulty: int, music_stage: int) -> int:
	if game_mode == "endless":
		return clampi(endless_difficulty, 1, 4)
	return clampi(music_stage, 1, 3)
