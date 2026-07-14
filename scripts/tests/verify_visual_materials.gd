extends SceneTree

const VisualMaterialsUtil := preload("res://scripts/core/visual_materials.gd")


func _init() -> void:
	var color := Color(0.2, 0.8, 1.0)
	var face := VisualMaterialsUtil.flat_face(color, 0.30, 0.60)
	var line := VisualMaterialsUtil.outline(color, 0.95, 2.0)
	var transparent_line := VisualMaterialsUtil.transparent_outline(color, 0.55, 0.7)

	assert(face.shader == VisualMaterialsUtil.FLAT_TRANSPARENT_SHADER)
	assert(line.shader == VisualMaterialsUtil.EMISSIVE_OUTLINE_SHADER)
	assert(transparent_line.shader == VisualMaterialsUtil.TRANSPARENT_OUTLINE_SHADER)
	assert(is_equal_approx((face.get_shader_parameter("face_color") as Color).a, 0.30))
	assert(is_equal_approx(float(face.get_shader_parameter("emission_strength")), 0.60))
	assert(is_equal_approx((line.get_shader_parameter("line_color") as Color).a, 0.95))
	assert(is_equal_approx(float(line.get_shader_parameter("emission_strength")), 2.0))
	assert(is_equal_approx((transparent_line.get_shader_parameter("line_color") as Color).a, 0.55))
	assert(is_equal_approx(float(transparent_line.get_shader_parameter("emission_strength")), 0.7))
	quit()
