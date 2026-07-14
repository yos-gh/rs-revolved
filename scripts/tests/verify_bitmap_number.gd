extends SceneTree

const BitmapNumberUtil := preload("res://scripts/ui/bitmap_number.gd")
const SCORE_ATLAS := preload("res://assets/ui/original_svg/score.svg")
const ZANKI_ATLAS := preload("res://assets/ui/original_svg/zanki.svg")


func _init() -> void:
	assert(not FileAccess.get_file_as_string("res://assets/ui/original_svg/score.svg").contains("#000000"))
	assert(not FileAccess.get_file_as_string("res://assets/ui/original_svg/zanki.svg").contains("#000000"))
	assert(not FileAccess.get_file_as_string("res://assets/ui/original_svg/score.svg").contains("#ffffff"))
	assert(not FileAccess.get_file_as_string("res://assets/ui/original_svg/zanki.svg").contains("#ffffff"))

	var score_digits := BitmapNumberUtil.new()
	root.add_child(score_digits)
	score_digits.setup(SCORE_ATLAS)
	score_digits.set_number(12345, 9, 9)
	assert(score_digits.digits == "000012345")
	assert(score_digits.digit_textures.size() == 10)
	assert(score_digits.digit_textures[0].region == Rect2(0, 0, 30, 16))
	assert(score_digits.digit_textures[9].region == Rect2(270, 0, 30, 16))
	assert(score_digits.custom_minimum_size.is_equal_approx(Vector2(238, 16)))

	var life_digit := BitmapNumberUtil.new()
	root.add_child(life_digit)
	life_digit.setup(ZANKI_ATLAS)
	life_digit.set_number(12, 1, 1)
	assert(life_digit.digits == "9")
	assert(life_digit.custom_minimum_size.is_equal_approx(Vector2(30, 16)))

	score_digits.queue_free()
	life_digit.queue_free()
	await process_frame
	await process_frame
	print("bitmap number verification passed")
	quit()
