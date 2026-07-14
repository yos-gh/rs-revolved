class_name BitmapNumber
extends Control

const DIGIT_COUNT := 10

var digit_textures: Array[AtlasTexture] = []
var digit_size := Vector2i(30, 16)
var cell_stride := 30
var digit_spacing := 26
var display_scale := 1.0
var digits := "0"


func setup(atlas: Texture2D, size := Vector2i(30, 16), stride := 30, spacing := 26, scale := 1.0) -> void:
	digit_size = size
	cell_stride = stride
	digit_spacing = spacing
	display_scale = scale
	digit_textures.clear()
	for digit in range(DIGIT_COUNT):
		var texture := AtlasTexture.new()
		texture.atlas = atlas
		texture.region = Rect2i(digit * cell_stride, 0, digit_size.x, digit_size.y)
		digit_textures.append(texture)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_update_size()
	queue_redraw()


func set_number(value: int, minimum_digits := 1, maximum_digits := 9) -> void:
	var safe_maximum := maxi(1, maximum_digits)
	var max_value := int(pow(10.0, float(safe_maximum))) - 1
	var next_digits := str(clampi(value, 0, max_value))
	while next_digits.length() < minimum_digits:
		next_digits = "0" + next_digits
	if next_digits.length() > safe_maximum:
		next_digits = next_digits.right(safe_maximum)
	if digits == next_digits:
		return
	digits = next_digits
	_update_size()
	queue_redraw()


func _draw() -> void:
	if digit_textures.size() != DIGIT_COUNT:
		return
	var draw_size := Vector2(digit_size) * display_scale
	for index in range(digits.length()):
		var digit := digits.unicode_at(index) - 48
		if digit < 0 or digit >= DIGIT_COUNT:
			continue
		var draw_position := Vector2(float(index * digit_spacing) * display_scale, 0.0)
		draw_texture_rect(digit_textures[digit], Rect2(draw_position, draw_size), false)


func _update_size() -> void:
	var width := digit_size.x
	if digits.length() > 1:
		width += (digits.length() - 1) * digit_spacing
	custom_minimum_size = Vector2(float(width), float(digit_size.y)) * display_scale
	size = custom_minimum_size
