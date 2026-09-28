class_name BulletTimeGlitch
extends ColorRect

const POST_SHADER := preload("res://assets/shaders/bullet_time_post.gdshader")

const MIN_VISIBLE_INTENSITY := 0.02
const BURST_DECAY := 9.0
const BURST_CHANCE_PER_BEAT := 0.28
const FALLBACK_BEAT_SECONDS := 0.5
const BEATS_PER_BAR := 4
const BEATS_PER_RING := 2
const OFFBEAT_PULSE := 0.5
const PULSE_DECAY := 8.0

# Radii are in screen heights. Colour-only effects fade in from CLEAR_RADIUS; effects
# that move pixels stay off until SHIFT_CLEAR_RADIUS so nearby threats keep their position.
const CLEAR_RADIUS := 0.12
const SOFT_RADIUS := 0.26
const SHIFT_CLEAR_RADIUS := 0.20
const SHIFT_SOFT_RADIUS := 0.30

var player_screen_pos := Vector2.ZERO
var intensity := 0.0
var _time := 0.0
var _burst := 0.0
var _burst_seed := 0.0
var _free_beat := 0.0
var _last_beat_index := -1
var _beat_env := 0.0
var _ring_age := 10.0
var _rng := RandomNumberGenerator.new()
var _post_material: ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_rng.seed = 0x5EED
	_post_material = ShaderMaterial.new()
	_post_material.shader = POST_SHADER
	_post_material.set_shader_parameter("clear_radius", CLEAR_RADIUS)
	_post_material.set_shader_parameter("soft_radius", SOFT_RADIUS)
	_post_material.set_shader_parameter("shift_clear_radius", SHIFT_CLEAR_RADIUS)
	_post_material.set_shader_parameter("shift_soft_radius", SHIFT_SOFT_RADIUS)
	material = _post_material
	_sync_viewport_rect()


# `beat_position` is the BGM position in beats (negative when no music is playing) and
# `beat_seconds` its beat length, so pulses land on the soundtrack's own tempo.
func update_effect(delta: float, player_pos: Vector2, target_intensity: float, beat_position := -1.0, beat_seconds := FALLBACK_BEAT_SECONDS) -> void:
	_sync_viewport_rect()
	player_screen_pos = player_pos
	intensity = lerpf(intensity, clampf(target_intensity, 0.0, 1.0), minf(1.0, delta * 8.0))
	_time += delta
	_update_beat(delta, beat_position, beat_seconds)
	visible = intensity > MIN_VISIBLE_INTENSITY
	if not visible:
		return
	_post_material.set_shader_parameter("intensity", intensity)
	_post_material.set_shader_parameter("time", _time)
	_post_material.set_shader_parameter("canvas_size", size)
	_post_material.set_shader_parameter("focus_px", player_screen_pos)
	_post_material.set_shader_parameter("beat_env", _beat_env)
	_post_material.set_shader_parameter("ring_age", _ring_age)
	_post_material.set_shader_parameter("burst", _burst)
	_post_material.set_shader_parameter("burst_seed", _burst_seed)


func _update_beat(delta: float, beat_position: float, beat_seconds: float) -> void:
	if beat_position < 0.0:
		_free_beat += delta / FALLBACK_BEAT_SECONDS
		beat_position = _free_beat
		beat_seconds = FALLBACK_BEAT_SECONDS
	var beat_index := floori(beat_position)
	var beat_age := (beat_position - float(beat_index)) * beat_seconds
	var accent := 1.0 if posmod(beat_index, BEATS_PER_BAR) == 0 else OFFBEAT_PULSE
	_beat_env = accent * exp(-beat_age * PULSE_DECAY)
	_ring_age = fposmod(beat_position, float(BEATS_PER_RING)) * beat_seconds

	# Glitch bursts land on beats; their odds and strength follow the slowdown amount.
	_burst = maxf(0.0, _burst - delta * BURST_DECAY)
	if beat_index != _last_beat_index:
		_last_beat_index = beat_index
		if _rng.randf() < BURST_CHANCE_PER_BEAT * intensity:
			_burst = maxf(_burst, _rng.randf_range(0.5, 1.0) * intensity)
			_burst_seed = _rng.randf() * 100.0


func _sync_viewport_rect() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size
