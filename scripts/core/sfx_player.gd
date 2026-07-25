class_name SfxPlayer
extends Node

const TimeWarpAudioUtil := preload("res://scripts/core/time_warp_audio.gd")

signal event_played(event: String)

const STREAMS := {
	"shot": preload("res://assets/audio/runtime/original_mastered/shot.wav"),
	"bomb_s": preload("res://assets/audio/runtime/original_mastered/bomb_s.wav"),
	"bomb_m": preload("res://assets/audio/runtime/original_mastered/bomb_m.wav"),
	"die": preload("res://assets/audio/runtime/original_mastered/die.wav"),
	"extend": preload("res://assets/audio/runtime/original_mastered/extend.wav"),
	"gum_o": preload("res://assets/audio/runtime/original_mastered/gum_o.wav"),
	"gum_c": preload("res://assets/audio/runtime/original_mastered/gum_c.wav"),
}

const MAX_POLYPHONY := {
	"shot": 8,
	"bomb_s": 8,
	"bomb_m": 4,
	"die": 2,
	"extend": 2,
	"gum_o": 1,
	"gum_c": 1,
}

const ORIGINAL_VOLUME_RANGES := {
	"shot": Vector2i(4, 7),
	"bomb_s": Vector2i(32, 63),
	"bomb_m": Vector2i(32, 63),
	"die": Vector2i(64, 95),
	"extend": Vector2i(64, 64),
	"gum_o": Vector2i(32, 63),
	"gum_c": Vector2i(32, 63),
}

const ORIGINAL_VOLUME_MAX := 128.0
const DESTRUCTION_BUS_NAME := &"Destruction"
const SFX_MIX_BUS_NAME := &"SfxMix"
const TIME_WARP_BUS_NAME := TimeWarpAudioUtil.BUS_NAME
const SFX_MIX_EFFECT_COUNT := 2
const SFX_DELAY_TAP_1_MS := 31.0
const SFX_DELAY_TAP_1_DB := -31.0
const SFX_DELAY_TAP_2_MS := 53.0
const SFX_DELAY_TAP_2_DB := -35.0
const SFX_REVERB_WET := 0.045
const DESTRUCTION_EVENTS := ["bomb_s", "bomb_m", "die"]
const DESTRUCTION_COMPRESSOR_THRESHOLD_DB := -6.0
const DESTRUCTION_COMPRESSOR_RATIO := 6.0
const DESTRUCTION_LIMITER_CEILING_DB := -1.0
const GUM_EVENTS := ["gum_o", "gum_c"]
const GUM_FADE_OUT_TIME := 0.055
const GUM_FADE_IN_TIME := 0.035
const GUM_FADE_FLOOR_DB := -60.0
const GUM_MIN_REVERSE_SEGMENT := 0.30

var _players: Dictionary = {}
var _gum_tweens: Dictionary = {}


func setup() -> void:
	name = "SfxPlayer"
	TimeWarpAudioUtil.ensure_bus()
	_ensure_sfx_mix_bus()
	_ensure_destruction_bus()
	for event in STREAMS:
		var player := AudioStreamPlayer.new()
		player.name = "Sfx%s" % String(event).to_pascal_case()
		player.stream = STREAMS[event]
		player.max_polyphony = MAX_POLYPHONY[event]
		if event in DESTRUCTION_EVENTS:
			player.bus = DESTRUCTION_BUS_NAME
		else:
			player.bus = SFX_MIX_BUS_NAME
		add_child(player)
		_players[event] = player


func _ensure_sfx_mix_bus() -> void:
	var bus_index := AudioServer.get_bus_index(SFX_MIX_BUS_NAME)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, SFX_MIX_BUS_NAME)
	AudioServer.set_bus_send(bus_index, TIME_WARP_BUS_NAME)
	if AudioServer.get_bus_effect_count(bus_index) == SFX_MIX_EFFECT_COUNT:
		return
	while AudioServer.get_bus_effect_count(bus_index) > 0:
		AudioServer.remove_bus_effect(bus_index, 0)

	var delay := AudioEffectDelay.new()
	delay.resource_name = "SharedEarlyReflections"
	delay.dry = 1.0
	delay.tap1_active = true
	delay.tap1_delay_ms = SFX_DELAY_TAP_1_MS
	delay.tap1_level_db = SFX_DELAY_TAP_1_DB
	delay.tap1_pan = -0.24
	delay.tap2_active = true
	delay.tap2_delay_ms = SFX_DELAY_TAP_2_MS
	delay.tap2_level_db = SFX_DELAY_TAP_2_DB
	delay.tap2_pan = 0.24
	delay.feedback_active = false
	AudioServer.add_bus_effect(bus_index, delay)

	var reverb := AudioEffectReverb.new()
	reverb.resource_name = "SharedDryRoom"
	reverb.room_size = 0.34
	reverb.damping = 0.78
	reverb.spread = 0.72
	reverb.hipass = 0.32
	reverb.dry = 1.0
	reverb.wet = SFX_REVERB_WET
	AudioServer.add_bus_effect(bus_index, reverb)


func _ensure_destruction_bus() -> void:
	var bus_index := AudioServer.get_bus_index(DESTRUCTION_BUS_NAME)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, DESTRUCTION_BUS_NAME)
	AudioServer.set_bus_send(bus_index, SFX_MIX_BUS_NAME)
	if AudioServer.get_bus_effect_count(bus_index) == 2:
		return
	while AudioServer.get_bus_effect_count(bus_index) > 0:
		AudioServer.remove_bus_effect(bus_index, 0)

	var compressor := AudioEffectCompressor.new()
	compressor.resource_name = "BurstCompressor"
	compressor.threshold = DESTRUCTION_COMPRESSOR_THRESHOLD_DB
	compressor.ratio = DESTRUCTION_COMPRESSOR_RATIO
	compressor.attack_us = 1000.0
	compressor.release_ms = 100.0
	compressor.mix = 1.0
	AudioServer.add_bus_effect(bus_index, compressor)

	var limiter := AudioEffectHardLimiter.new()
	limiter.resource_name = "PeakGuard"
	limiter.ceiling_db = DESTRUCTION_LIMITER_CEILING_DB
	limiter.pre_gain_db = 0.0
	limiter.release = 0.08
	AudioServer.add_bus_effect(bus_index, limiter)


func play(event: String, volume_range := Vector2i(-1, -1)) -> void:
	var player := _players.get(event) as AudioStreamPlayer
	if player == null:
		return
	var selected_range: Vector2i = ORIGINAL_VOLUME_RANGES[event] if volume_range.x < 0 else volume_range
	var original_volume := randi_range(selected_range.x, selected_range.y)
	var target_volume_db := linear_to_db(float(original_volume) / ORIGINAL_VOLUME_MAX)
	if event in GUM_EVENTS:
		_play_gum_transition(event, target_volume_db)
	else:
		player.volume_db = target_volume_db
		player.play()
	event_played.emit(event)


func _play_gum_transition(event: String, target_volume_db: float) -> void:
	var opposite_event := "gum_c" if event == "gum_o" else "gum_o"
	var player := _players[event] as AudioStreamPlayer
	var opposite_player := _players[opposite_event] as AudioStreamPlayer
	var start_position := 0.0
	if opposite_player.playing:
		var opposite_position := opposite_player.get_playback_position()
		var audible_progress := maxf(opposite_position, GUM_MIN_REVERSE_SEGMENT)
		start_position = clampf(player.stream.get_length() - audible_progress, 0.0, player.stream.get_length())
		_fade_out_gum(opposite_event)

	_cancel_gum_tween(event)
	player.stop()
	player.volume_db = maxf(GUM_FADE_FLOOR_DB, target_volume_db - 24.0)
	player.play(start_position)
	var tween := create_tween()
	_gum_tweens[event] = tween
	tween.tween_property(player, "volume_db", target_volume_db, GUM_FADE_IN_TIME)
	tween.tween_callback(func() -> void:
		if _gum_tweens.get(event) == tween:
			_gum_tweens.erase(event)
	)


func _fade_out_gum(event: String) -> void:
	_cancel_gum_tween(event)
	var player := _players[event] as AudioStreamPlayer
	var tween := create_tween()
	_gum_tweens[event] = tween
	tween.tween_property(player, "volume_db", GUM_FADE_FLOOR_DB, GUM_FADE_OUT_TIME)
	tween.tween_callback(func() -> void:
		if _gum_tweens.get(event) == tween:
			player.stop()
			_gum_tweens.erase(event)
	)


func _cancel_gum_tween(event: String) -> void:
	var tween := _gum_tweens.get(event) as Tween
	if tween != null:
		tween.kill()
		_gum_tweens.erase(event)


func stop_all() -> void:
	for event in GUM_EVENTS:
		_cancel_gum_tween(event)
	for player in _players.values():
		(player as AudioStreamPlayer).stop()


func has_event(event: String) -> bool:
	return _players.has(event)


func player_for(event: String) -> AudioStreamPlayer:
	return _players.get(event) as AudioStreamPlayer
