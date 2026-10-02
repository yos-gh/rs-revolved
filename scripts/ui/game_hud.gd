class_name GameHud
extends Control

const BitmapNumberUtil := preload("res://scripts/ui/bitmap_number.gd")
const SCORE_ATLAS := preload("res://assets/ui/original_svg/score.svg")
const ZANKI_ATLAS := preload("res://assets/ui/original_svg/zanki.svg")

const HUD_MARGIN := 28.0
const NUMBER_SCALE := 1.25
const SCORE_POSITION := Vector2(HUD_MARGIN, 28.0)
const GUM_MIN_RATIO := 0.18
const TENSION_COLOR := Color(0.50, 0.88, 0.38, 0.88)
const GUM_COLOR := Color(0.38, 0.50, 0.88, 0.88)
const GUM_LOW_COLOR := Color(0.88, 0.50, 0.38, 0.90)
# A brief glow when Gum becomes usable again or a meter tops out.
const READY_FLASH_TIME := 0.55
# Topping out Tension is rare and hard won, so its glow lingers and fades.
const TENSION_FLASH_TIME := 2.4
const LIFE_FLASH_TIME := 0.8
# Tension decays every frame, so "full" is a band with hysteresis rather than exactly 1.0.
const TENSION_FULL_RATIO := 0.995
const TENSION_REARM_RATIO := 0.90

var score_digits: BitmapNumber
var life_digit: BitmapNumber
var debug_label: Label
var gum_track: ColorRect
var gum_fill: ColorRect
var gum_threshold: ColorRect
var tension_track: ColorRect
var tension_fill: ColorRect
var gum_ratio := 1.0
var tension_ratio := 0.0
var gum_flash := 0.0
var tension_flash := 0.0
var tension_flash_armed := true
var life_flash := 0.0


func setup() -> void:
	name = "GameHud"
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_sync_viewport_size()
	if not get_viewport().size_changed.is_connected(_sync_viewport_size):
		get_viewport().size_changed.connect(_sync_viewport_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# The original HUD is intentionally sparse: Tension above the score and Gum along the floor.
	tension_track = _add_edge_meter("Tension", false)
	tension_fill = _add_meter_fill(tension_track, TENSION_COLOR)

	score_digits = _add_bitmap_number(SCORE_ATLAS, SCORE_POSITION, false, false, NUMBER_SCALE)
	score_digits.set_number(0, 9, 9)

	debug_label = _add_debug_label()
	debug_label.visible = false

	gum_track = _add_edge_meter("Gum", true)
	gum_fill = _add_meter_fill(gum_track, GUM_COLOR)
	gum_threshold = ColorRect.new()
	gum_threshold.name = "MinimumMarker"
	gum_threshold.color = Color(0.50, 0.64, 0.50, 0.72)
	gum_threshold.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gum_threshold.size = Vector2(2.0, 12.0)
	gum_track.add_child(gum_threshold)

	life_digit = _add_bitmap_number(ZANKI_ATLAS, Vector2(-HUD_MARGIN - 30.0 * NUMBER_SCALE, -48.0), true, true, NUMBER_SCALE)
	life_digit.set_number(0, 1, 1)
	life_digit.prepare_glow()
	_update_meter_geometry()


func update_values(score: int, _hi_score: int, lives: int, gum_energy: float, tension: float, _phase: String, _rank: int, _life_state: String, _gum_state: String, debug_text: String) -> void:
	score_digits.set_number(score, 9, 9)
	life_digit.set_number(lives, 1, 1)
	var next_gum := clampf(gum_energy, 0.0, 1.0)
	var next_tension := clampf(tension / 360.0, 0.0, 1.0)
	if (gum_ratio <= GUM_MIN_RATIO and next_gum > GUM_MIN_RATIO) or (gum_ratio < 1.0 and next_gum >= 1.0):
		gum_flash = 1.0
	if next_tension < TENSION_REARM_RATIO:
		tension_flash_armed = true
	elif tension_flash_armed and next_tension >= TENSION_FULL_RATIO:
		tension_flash_armed = false
		tension_flash = 1.0
	var was_full := _gum_full()
	gum_ratio = next_gum
	tension_ratio = next_tension
	if was_full != _gum_full():
		queue_redraw()
	_apply_fill_colors()
	debug_label.text = debug_text
	debug_label.visible = not debug_text.is_empty()
	_update_meter_geometry()


func flash_life() -> void:
	life_flash = 1.0
	life_digit.set_glow(_flash_curve(life_flash))
	set_process(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_instance_valid(gum_track):
		_update_meter_geometry()


func _process(delta: float) -> void:
	if life_flash > 0.0:
		life_flash = maxf(0.0, life_flash - delta / LIFE_FLASH_TIME)
		life_digit.set_glow(_flash_curve(life_flash))
	if gum_flash <= 0.0 and tension_flash <= 0.0 and not _gum_full():
		return
	gum_flash = maxf(0.0, gum_flash - delta / READY_FLASH_TIME)
	tension_flash = maxf(0.0, tension_flash - delta / TENSION_FLASH_TIME)
	_apply_fill_colors()
	queue_redraw()


# A full Gum meter keeps glowing until it is spent.
func _gum_glow() -> float:
	return 1.0 if _gum_full() else gum_flash


func _gum_full() -> bool:
	return gum_ratio >= 1.0


func _apply_fill_colors() -> void:
	gum_fill.color = GUM_LOW_COLOR if gum_ratio < GUM_MIN_RATIO else _flash_color(GUM_COLOR, _gum_glow())
	tension_fill.color = _flash_color(TENSION_COLOR, tension_flash)


func _flash_color(color: Color, flash: float) -> Color:
	return color.lerp(Color(color.lightened(0.55), 1.0), _flash_curve(flash))


func _flash_curve(flash: float) -> float:
	# Quick rise, soft tail.
	return flash * flash


func _draw() -> void:
	if not is_instance_valid(gum_track) or not is_instance_valid(tension_track):
		return
	_draw_meter_glow(tension_fill, TENSION_COLOR, tension_flash)
	_draw_meter_glow(gum_fill, GUM_COLOR, _gum_glow())


func _draw_meter_glow(fill: ColorRect, color: Color, flash: float) -> void:
	if flash <= 0.0 or fill.size.x <= 0.0:
		return
	var rect := Rect2(fill.get_parent().position + fill.position, fill.size)
	var strength := _flash_curve(flash)
	var glow := color.lightened(0.3)
	for layer in [[6.0, 0.10], [3.0, 0.18], [1.0, 0.30]]:
		draw_rect(rect.grow_individual(layer[0], layer[0], layer[0], layer[0]), Color(glow, layer[1] * strength))


func _sync_viewport_size() -> void:
	size = get_viewport_rect().size
	_update_meter_geometry()
	queue_redraw()


func _add_bitmap_number(atlas: Texture2D, offset: Vector2, anchor_right := false, anchor_bottom := false, display_scale := 1.0) -> BitmapNumber:
	var number := BitmapNumberUtil.new()
	number.setup(atlas, Vector2i(30, 16), 30, 26, display_scale)
	if anchor_right:
		number.anchor_left = 1.0
		number.anchor_right = 1.0
	if anchor_bottom:
		number.anchor_top = 1.0
		number.anchor_bottom = 1.0
	number.position = offset
	add_child(number)
	return number


func _add_edge_meter(meter_name: String, at_bottom: bool) -> ColorRect:
	var track := ColorRect.new()
	track.name = meter_name
	track.anchor_right = 1.0
	track.offset_left = HUD_MARGIN
	track.offset_right = -HUD_MARGIN
	if at_bottom:
		track.anchor_top = 1.0
		track.anchor_bottom = 1.0
		# Mirrors the Tension track: 18px from the edge, same gap to the life digit as to the score.
		track.offset_top = -21.0
		track.offset_bottom = -18.0
	else:
		track.offset_top = 18.0
		track.offset_bottom = 21.0
	track.color = Color(0.18, 0.21, 0.22, 0.42)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(track)
	return track


func _add_meter_fill(track: ColorRect, color: Color) -> ColorRect:
	var fill := ColorRect.new()
	fill.name = "Fill"
	fill.color = color
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.size = Vector2(0.0, 3.0)
	track.add_child(fill)
	return fill


func _add_debug_label() -> Label:
	var label := Label.new()
	label.position = Vector2(HUD_MARGIN, 52.0)
	label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.80, 0.76))
	label.add_theme_font_size_override("font_size", 11)
	add_child(label)
	return label


func _update_meter_geometry() -> void:
	if not is_instance_valid(gum_track) or not is_instance_valid(tension_track):
		return
	var gum_width := maxf(0.0, gum_track.size.x)
	var tension_width := maxf(0.0, tension_track.size.x)
	gum_fill.size = Vector2(gum_width * gum_ratio, 3.0)
	tension_fill.size = Vector2(tension_width * tension_ratio, 3.0)
	gum_threshold.position = Vector2(gum_width * GUM_MIN_RATIO, -4.0)
