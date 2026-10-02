class_name BitmapNumber
extends Control

const DIGIT_COUNT := 10
# Screen-pixel grow and alpha per layer, the same stack GameHud draws around its meters.
const HALO_LAYERS := [[6.0, 0.10], [3.0, 0.18], [1.0, 0.30]]

var digit_textures: Array[AtlasTexture] = []
var digit_size := Vector2i(30, 16)
var cell_stride := 30
var digit_spacing := 26
var display_scale := 1.0
var digits := "0"
# 0..1, already eased. Mirrors the HUD meter glow: lightened digits plus a soft square halo.
var glow := 0.0
var lit_textures: Array[ImageTexture] = []
var halo_textures: Array[ImageTexture] = []


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
	lit_textures.clear()
	halo_textures.clear()
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


func prepare_glow() -> void:
	if lit_textures.is_empty():
		_build_glow_textures()


func set_glow(value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	if is_equal_approx(value, glow):
		return
	glow = value
	if glow > 0.0:
		prepare_glow()
	queue_redraw()


func _draw() -> void:
	if digit_textures.size() != DIGIT_COUNT:
		return
	var draw_size := Vector2(digit_size) * display_scale
	var glowing := glow > 0.0 and lit_textures.size() == DIGIT_COUNT
	var halo_pad := Vector2.ONE * float(_halo_pad()) * display_scale
	for index in range(digits.length()):
		var digit := digits.unicode_at(index) - 48
		if digit < 0 or digit >= DIGIT_COUNT:
			continue
		var draw_position := Vector2(float(index * digit_spacing) * display_scale, 0.0)
		if glowing:
			draw_texture_rect(halo_textures[digit], Rect2(draw_position - halo_pad, draw_size + halo_pad * 2.0), false, Color(1.0, 1.0, 1.0, glow))
		draw_texture_rect(digit_textures[digit], Rect2(draw_position, draw_size), false)
		if glowing:
			draw_texture_rect(lit_textures[digit], Rect2(draw_position, draw_size), false, Color(1.0, 1.0, 1.0, glow))


func _build_glow_textures() -> void:
	lit_textures.clear()
	halo_textures.clear()
	if digit_textures.is_empty():
		return
	var atlas_image := digit_textures[0].atlas.get_image()
	if atlas_image.is_compressed():
		atlas_image.decompress()
	atlas_image.convert(Image.FORMAT_RGBA8)
	# Halo radii are given in screen pixels; the halo image lives in atlas pixels.
	var pad := _halo_pad()
	for digit in range(DIGIT_COUNT):
		var glyph := atlas_image.get_region(Rect2i(digit * cell_stride, 0, digit_size.x, digit_size.y))
		var lit := Image.create(digit_size.x, digit_size.y, false, Image.FORMAT_RGBA8)
		var halo := Image.create(digit_size.x + pad * 2, digit_size.y + pad * 2, false, Image.FORMAT_RGBA8)
		var ink: Array[Vector2i] = []
		var ink_color := Color.WHITE
		for y in range(digit_size.y):
			for x in range(digit_size.x):
				var color := glyph.get_pixel(x, y)
				if color.a <= 0.0:
					continue
				ink.append(Vector2i(x, y))
				ink_color = color
				lit.set_pixel(x, y, Color(color.lightened(0.55), 1.0))
		var glow_color := ink_color.lightened(0.3)
		var width := halo.get_width()
		var height := halo.get_height()
		var keep := PackedFloat32Array()
		keep.resize(width * height)
		keep.fill(1.0)
		for layer in HALO_LAYERS:
			var covered := _dilate(ink, pad, width, height, roundi(layer[0] / display_scale))
			for i in range(covered.size()):
				if covered[i]:
					keep[i] *= 1.0 - layer[1]
		for i in range(keep.size()):
			if keep[i] < 1.0:
				halo.set_pixel(i % width, i / width, Color(glow_color, 1.0 - keep[i]))
		lit_textures.append(ImageTexture.create_from_image(lit))
		halo_textures.append(ImageTexture.create_from_image(halo))


func _update_size() -> void:
	var width := digit_size.x
	if digits.length() > 1:
		width += (digits.length() - 1) * digit_spacing
	custom_minimum_size = Vector2(float(width), float(digit_size.y)) * display_scale
	size = custom_minimum_size


func _halo_pad() -> int:
	return ceili(HALO_LAYERS[0][0] / display_scale)


# Square grow of the ink mask, like Rect2.grow on the meters.
func _dilate(ink: Array[Vector2i], pad: int, width: int, height: int, radius: int) -> PackedByteArray:
	var rows := PackedByteArray()
	rows.resize(width * height)
	for point in ink:
		var y := point.y + pad
		for x in range(maxi(0, point.x + pad - radius), mini(width, point.x + pad + radius + 1)):
			rows[y * width + x] = 1
	var covered := PackedByteArray()
	covered.resize(width * height)
	for y in range(height):
		for x in range(width):
			if rows[y * width + x] == 0:
				continue
			for yy in range(maxi(0, y - radius), mini(height, y + radius + 1)):
				covered[yy * width + x] = 1
	return covered
