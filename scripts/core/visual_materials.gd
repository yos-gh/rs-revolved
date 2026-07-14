class_name VisualMaterials
extends RefCounted

const FLAT_TRANSPARENT_SHADER := preload("res://assets/shaders/flat_transparent.gdshader")
const FLAT_OVERLAY_SHADER := preload("res://assets/shaders/flat_overlay.gdshader")
const EMISSIVE_OUTLINE_SHADER := preload("res://assets/shaders/emissive_outline.gdshader")
const TRANSPARENT_OUTLINE_SHADER := preload("res://assets/shaders/transparent_outline.gdshader")


static func flat_face(color: Color, alpha := 0.28, emission_strength := 0.55) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = FLAT_TRANSPARENT_SHADER
	material.set_shader_parameter("face_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("emission_strength", emission_strength)
	return material


static func overlay_face(color: Color, alpha := 0.28, emission_strength := 0.55, priority := 6) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = FLAT_OVERLAY_SHADER
	material.render_priority = priority
	material.set_shader_parameter("face_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("emission_strength", emission_strength)
	return material


static func outline(color: Color, alpha := 0.90, emission_strength := 1.8) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = EMISSIVE_OUTLINE_SHADER
	material.set_shader_parameter("line_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("emission_strength", emission_strength)
	return material


static func transparent_outline(color: Color, alpha := 0.60, emission_strength := 0.6) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = TRANSPARENT_OUTLINE_SHADER
	material.set_shader_parameter("line_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("emission_strength", emission_strength)
	return material
