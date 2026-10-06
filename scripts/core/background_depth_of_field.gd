class_name BackgroundDepthOfField
extends Node3D

# Renders background geometry on BACKGROUND_LAYER through a mirror camera into its own
# viewport, then draws it back behind gameplay on a screen-mapped quad with a blur that
# deepens toward the tunnel's vanishing point. Gameplay objects never pass through it.

const DOF_SHADER := preload("res://assets/shaders/background_dof.gdshader")

const BACKGROUND_LAYER := 1 << 19
# Afterimages get their own pass so they can blur more than the tunnel.
const AFTERIMAGE_LAYER := 1 << 18
const QUAD_SIZE := 400.0

var viewport: SubViewport
var camera: Camera3D
var quad: MeshInstance3D
var material: ShaderMaterial
var _source_camera: Camera3D
# Fraction of the screen resolution the pass renders at. The blur radius is set in screen
# pixels, so a softly blurred pass can render smaller without changing how wide it spreads.
var resolution_scale := 1.0
var _layer := BACKGROUND_LAYER


func setup(source_camera: Camera3D, source_environment: Environment, height: float, near_radius: float, layer := BACKGROUND_LAYER) -> void:
	name = "BackgroundDepthOfField" if layer == BACKGROUND_LAYER else "AfterimageDepthOfField"
	_source_camera = source_camera
	_layer = layer
	_source_camera.cull_mask &= ~layer

	viewport = SubViewport.new()
	viewport.name = "BackgroundViewport"
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = get_viewport().msaa_3d
	add_child(viewport)

	# Same lighting as the main view, but no glow here: the main pass glows the composite.
	var environment := source_environment.duplicate() as Environment
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.glow_enabled = false
	camera = Camera3D.new()
	camera.name = "BackgroundCamera"
	camera.cull_mask = layer
	camera.environment = environment
	viewport.add_child(camera)

	material = ShaderMaterial.new()
	material.shader = DOF_SHADER
	material.set_shader_parameter("bg_tex", viewport.get_texture())
	material.set_shader_parameter("near_radius", near_radius)
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(QUAD_SIZE, QUAD_SIZE)
	quad = MeshInstance3D.new()
	quad.name = "BackgroundComposite"
	quad.mesh = mesh
	quad.material_override = material
	quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	quad.position = Vector3(0.0, height, 0.0)
	add_child(quad)
	_sync_camera()


static func assign_layer(instance: VisualInstance3D, layer := BACKGROUND_LAYER) -> void:
	instance.layers = layer


func set_blur(near_px: float, far_px: float) -> void:
	material.set_shader_parameter("near_blur_px", near_px)
	material.set_shader_parameter("far_blur_px", far_px)


func update_focus(vanish_point: Vector2, ring_squash: float) -> void:
	_sync_camera()
	material.set_shader_parameter("vanish_world", vanish_point)
	material.set_shader_parameter("ring_squash", ring_squash)


func set_background_visible(value: bool) -> void:
	quad.visible = value


# Turns the separate blurred pass on or off. When off, `draw_direct` lets the main camera draw
# the layer itself (sharp, no extra render); otherwise the layer is simply not drawn.
func set_pass_enabled(enabled: bool, draw_direct := false) -> void:
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_DISABLED
	quad.visible = enabled
	if enabled or not draw_direct:
		_source_camera.cull_mask &= ~_layer
	else:
		_source_camera.cull_mask |= _layer


func _sync_camera() -> void:
	var render_size := Vector2i((Vector2(get_viewport().get_texture().get_size()) * resolution_scale).round())
	if viewport.size != render_size and render_size.x > 0 and render_size.y > 0:
		viewport.size = render_size
	material.set_shader_parameter("px_scale", float(render_size.y) / 720.0)
	camera.global_transform = _source_camera.global_transform
	camera.projection = _source_camera.projection
	camera.size = _source_camera.size
	camera.keep_aspect = _source_camera.keep_aspect
	camera.near = _source_camera.near
	camera.far = _source_camera.far
