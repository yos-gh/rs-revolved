class_name TimeWarpAudio
extends Node

const BUS_NAME := &"TimeWarp"
const EFFECT_COUNT := 4
const NORMAL_CUTOFF_HZ := 20500.0
const SUBMERGED_CUTOFF_HZ := 2600.0
const MAX_DELAY_TAP_1_DB := -18.0
const MAX_DELAY_TAP_2_DB := -22.0
const MAX_DELAY_FEEDBACK_DB := -26.0
const MAX_REVERB_WET := 0.22
const MAX_NOISE_VOLUME_DB := -32.0
const SILENT_DB := -60.0

var intensity := 0.0
var low_pass: AudioEffectLowPassFilter
var delay: AudioEffectDelay
var reverb: AudioEffectReverb
var limiter: AudioEffectHardLimiter
var noise_player: AudioStreamPlayer
var noise_playback: AudioStreamGeneratorPlayback
var _noise_seed := 0x13579BDF
var _noise_left := 0.0
var _noise_right := 0.0


static func ensure_bus() -> int:
	var bus_index := AudioServer.get_bus_index(BUS_NAME)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, BUS_NAME)
	AudioServer.set_bus_send(bus_index, &"Master")
	if AudioServer.get_bus_effect_count(bus_index) != EFFECT_COUNT:
		while AudioServer.get_bus_effect_count(bus_index) > 0:
			AudioServer.remove_bus_effect(bus_index, 0)
		_add_effects(bus_index)
	return bus_index


static func _add_effects(bus_index: int) -> void:
	var low_pass := AudioEffectLowPassFilter.new()
	low_pass.resource_name = "SubmergedLowPass"
	low_pass.cutoff_hz = NORMAL_CUTOFF_HZ
	low_pass.resonance = 0.18
	AudioServer.add_bus_effect(bus_index, low_pass)

	var delay := AudioEffectDelay.new()
	delay.resource_name = "FallingEcho"
	delay.dry = 1.0
	delay.tap1_active = true
	delay.tap1_delay_ms = 92.0
	delay.tap1_level_db = SILENT_DB
	delay.tap1_pan = -0.35
	delay.tap2_active = true
	delay.tap2_delay_ms = 137.0
	delay.tap2_level_db = SILENT_DB
	delay.tap2_pan = 0.35
	delay.feedback_active = true
	delay.feedback_delay_ms = 184.0
	delay.feedback_level_db = SILENT_DB
	delay.feedback_lowpass = 3400.0
	AudioServer.add_bus_effect(bus_index, delay)

	var reverb := AudioEffectReverb.new()
	reverb.resource_name = "TunnelDepth"
	reverb.room_size = 0.78
	reverb.damping = 0.82
	reverb.spread = 0.92
	reverb.hipass = 0.18
	reverb.dry = 1.0
	reverb.wet = 0.0
	AudioServer.add_bus_effect(bus_index, reverb)

	var limiter := AudioEffectHardLimiter.new()
	limiter.resource_name = "TimeWarpPeakGuard"
	limiter.ceiling_db = -0.8
	limiter.pre_gain_db = 0.0
	limiter.release = 0.10
	AudioServer.add_bus_effect(bus_index, limiter)


func setup() -> void:
	var bus_index := ensure_bus()
	low_pass = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectLowPassFilter
	delay = AudioServer.get_bus_effect(bus_index, 1) as AudioEffectDelay
	reverb = AudioServer.get_bus_effect(bus_index, 2) as AudioEffectReverb
	limiter = AudioServer.get_bus_effect(bus_index, 3) as AudioEffectHardLimiter

	if _is_web_runtime():
		update_effect(0.0)
		return

	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 48000.0
	generator.buffer_length = 0.35
	noise_player = AudioStreamPlayer.new()
	noise_player.name = "SubmergedNoise"
	noise_player.stream = generator
	noise_player.bus = BUS_NAME
	noise_player.volume_db = SILENT_DB
	add_child(noise_player)
	noise_player.play()
	noise_playback = noise_player.get_stream_playback() as AudioStreamGeneratorPlayback
	update_effect(0.0)


func _exit_tree() -> void:
	if is_instance_valid(noise_player):
		noise_player.stop()
	noise_playback = null


func update_effect(value: float) -> void:
	intensity = clampf(value, 0.0, 1.0)
	var shaped := intensity
	low_pass.cutoff_hz = exp(lerpf(log(NORMAL_CUTOFF_HZ), log(SUBMERGED_CUTOFF_HZ), shaped))
	low_pass.resonance = lerpf(0.18, 0.42, shaped)
	delay.tap1_level_db = lerpf(SILENT_DB, MAX_DELAY_TAP_1_DB, shaped)
	delay.tap2_level_db = lerpf(SILENT_DB, MAX_DELAY_TAP_2_DB, shaped)
	delay.feedback_level_db = lerpf(SILENT_DB, MAX_DELAY_FEEDBACK_DB, shaped)
	reverb.wet = MAX_REVERB_WET * shaped
	if noise_player != null:
		noise_player.volume_db = lerpf(SILENT_DB, MAX_NOISE_VOLUME_DB, shaped)
	_fill_noise_buffer()


func _fill_noise_buffer() -> void:
	if noise_playback == null:
		return
	for _frame in range(noise_playback.get_frames_available()):
		var white_left := _next_noise()
		var white_right := _next_noise()
		_noise_left += 0.025 * (white_left - _noise_left)
		_noise_right += 0.025 * (white_right - _noise_right)
		var shared := (_noise_left + _noise_right) * 0.28
		noise_playback.push_frame(Vector2(_noise_left * 0.72 + shared, _noise_right * 0.72 + shared))


func _next_noise() -> float:
	_noise_seed = int((_noise_seed * 1664525 + 1013904223) & 0x7FFFFFFF)
	return float(_noise_seed) / float(0x3FFFFFFF) - 1.0


func _is_web_runtime() -> bool:
	return OS.get_name() == "Web" or OS.has_feature("web")
