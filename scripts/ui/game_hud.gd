class_name GameHud
extends Control

const BitmapNumberUtil := preload("res://scripts/ui/bitmap_number.gd")
const SCORE_ATLAS := preload("res://assets/ui/original_svg/score.svg")
const ZANKI_ATLAS := preload("res://assets/ui/original_svg/zanki.svg")

const HUD_MARGIN := 28.0
const NUMBER_SCALE := 1.25
const GUM_MIN_RATIO := 0.18
const TENSION_COLOR := Color(0.50, 0.88, 0.38, 0.88)
const GUM_COLOR := Color(0.38, 0.50, 0.88, 0.88)
const GUM_LOW_COLOR := Color(0.88, 0.50, 0.38, 0.90)

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

	score_digits = _add_bitmap_number(SCORE_ATLAS, Vector2(HUD_MARGIN, 28.0), false, false, NUMBER_SCALE)
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

	life_digit = _add_bitmap_number(ZANKI_ATLAS, Vector2(-HUD_MARGIN - 30.0 * NUMBER_SCALE, -42.0), true, true, NUMBER_SCALE)
	life_digit.set_number(0, 1, 1)
	_update_meter_geometry()


func update_values(score: int, _hi_score: int, lives: int, gum_energy: float, tension: float, _phase: String, _rank: int, _life_state: String, _gum_state: String, debug_text: String) -> void:
	score_digits.set_number(score, 9, 9)
	life_digit.set_number(lives, 1, 1)
	gum_ratio = clampf(gum_energy, 0.0, 1.0)
	tension_ratio = clampf(tension / 360.0, 0.0, 1.0)
	gum_fill.color = GUM_LOW_COLOR if gum_ratio < GUM_MIN_RATIO else GUM_COLOR
	debug_label.text = debug_text
	debug_label.visible = not debug_text.is_empty()
	_update_meter_geometry()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_instance_valid(gum_track):
		_update_meter_geometry()


func _sync_viewport_size() -> void:
	size = get_viewport_rect().size
	_update_meter_geometry()


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
		track.offset_top = -20.0
		track.offset_bottom = -17.0
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
