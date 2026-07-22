extends Node3D

const CollisionUtil := preload("res://scripts/core/collision.gd")
const BulletTimeGlitchUtil := preload("res://scripts/core/bullet_time_glitch.gd")
const DebugOverlayUtil := preload("res://scripts/core/debug_overlay.gd")
const TimingUtil := preload("res://scripts/core/game_timing.gd")
const SfxPlayerUtil := preload("res://scripts/core/sfx_player.gd")
const BgmPlayerUtil := preload("res://scripts/core/bgm_player.gd")
const TimeWarpAudioUtil := preload("res://scripts/core/time_warp_audio.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")
const GameStateUtil := preload("res://scripts/game/game_state.gd")
const PlayerUtil := preload("res://scripts/game/player.gd")
const GumControllerUtil := preload("res://scripts/game/gum_controller.gd")
const BossGumControllerUtil := preload("res://scripts/game/boss_gum_controller.gd")
const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")
const SpawnerUtil := preload("res://scripts/game/spawner.gd")
const BossUtil := preload("res://scripts/game/boss.gd")
const ModelGalleryUtil := preload("res://scripts/gallery/model_gallery.gd")
const GameHudUtil := preload("res://scripts/ui/game_hud.gd")
const BitmapNumberUtil := preload("res://scripts/ui/bitmap_number.gd")
const SCORE_ATLAS := preload("res://assets/ui/original_svg/score.svg")
const MENU_ATLAS := preload("res://assets/ui/original_svg/menu.svg")
const TITLE_ATLAS := preload("res://assets/ui/original_svg/title.svg")
const VisualMaterialsUtil := preload("res://scripts/core/visual_materials.gd")
const VisualMotionUtil := preload("res://scripts/core/visual_motion.gd")

const BASE_FIELD_W := PlayfieldUtil.BASE_FIELD_W
const BASE_FIELD_H := PlayfieldUtil.BASE_FIELD_H
const PLAYFIELD_SCALE := PlayfieldUtil.SCALE
const FIELD_W := PlayfieldUtil.FIELD_W
const FIELD_H := PlayfieldUtil.FIELD_H
const FIELD_EDGE_MARGIN := 0.35
const DESPAWN_MARGIN := 1.6
const SPAWN_MARGIN := 0.65
const ENABLE_BOSS_MODE := true
const ARCADE_BGM_RANK_2 := 6
const ARCADE_BGM_RANK_3 := 11
const BOSS_CORE_VISUAL_SCALE := 1.30
const BOSS_CORE_RADIUS := 0.90 * BOSS_CORE_VISUAL_SCALE
const BOSS_CORE_LIFE := 800
const BOSS_DESTROY_ANTICIPATION_TIME := 0.22
const BOSS_DESTROY_SECOND_BURST_DELAY := 0.30
const BOSS_LIGHT_FALLOFF_DISTANCE := 10.0
const BOSS_LIGHT_LENGTH_MARGIN := 1.15
const BOSS_CORE_UNLOCK_RENDER_PRIORITY := 9
const BOSS_LIGHT_LEAK_SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform float beam_length = 1.0;
uniform float falloff_distance = 10.0;

void fragment() {
	float distance_from_core = UV.y * beam_length;
	float falloff = clamp(distance_from_core / falloff_distance, 0.0, 1.0);
	vec3 beam_color = mix(vec3(1.0, 1.0, 0.99), vec3(1.0, 0.97, 0.88), UV.y);
	float beam_alpha = mix(0.96, 0.34, falloff);
	float emission_energy = mix(3.80, 1.15, falloff);
	ALBEDO = beam_color;
	EMISSION = beam_color * emission_energy;
	ALPHA = beam_alpha;
}
"""
const BOSS_CORE_GUN_ORBIT_RADIUS := 0.96
const BOSS_CAGED_CORE_OUTLINE_WIDTH := 0.040
const BOSS_CAGED_PRIMARY_RING_WIDTH := 0.032
const BOSS_CAGED_SECONDARY_RING_WIDTH := 0.065
const BOSS_TURRET_RADIUS := 0.52
const BOSS_TURRET_VISUAL_SCALE := 1.40
const BOSS_TURRET_OVERALL_SCALE := 1.10
const BOSS_TURRET_VISUAL_HEIGHT := 0.52
const BOSS_T2_OPPOSING_GUN_HEIGHT_RATIO := 1.34
const BOSS_TURRET_RADII := {
	"boss_turret_t1": 0.86 * BOSS_TURRET_VISUAL_SCALE * BOSS_TURRET_OVERALL_SCALE,
	"boss_turret_t2": 0.82 * BOSS_TURRET_VISUAL_SCALE * BOSS_TURRET_OVERALL_SCALE,
	"boss_turret_t3": 0.76 * BOSS_TURRET_VISUAL_SCALE * BOSS_TURRET_OVERALL_SCALE,
}
const BOSS_TURRET_LIFE := 240
const BOSS_T_SLOW_GUN_EDGE_WIDTH := 0.015
const BOSS_T_RAPID_GUN_EDGE_WIDTH := 0.016
const BOSS_T_DIRECTION_GUN_EDGE_WIDTH := 0.017
const TUNNEL_RING_COUNT := 40
const TUNNEL_SEGMENTS := 24
const TUNNEL_FAR_RADIUS := 0.001
const TUNNEL_NEAR_RADIUS := 24.0
const TUNNEL_WIRE_MAX_LUMINANCE := 0.46
const TUNNEL_VISUAL_HEIGHT := 0.018
const TUNNEL_STREAM_LANES := 4
const TUNNEL_STREAM_PLATES_PER_LANE := 16
const TUNNEL_STREAM_HEIGHT := 0.028
const TUNNEL_STREAM_SPEED := 9.2
const TUNNEL_STREAM_ENABLED := false
const BACKGROUND_LIGHT_BASE_ROTATION := Vector3(-70.0, -25.0, 0.0)
const BACKGROUND_LIGHT_BREATH_DEPTH := 0.22
const BACKGROUND_LIGHT_BREATH_SPEED := 0.18
const GLOBAL_GLOW_ENABLED := true
const GAMEPAD_AIM_DEADZONE := 0.24

enum InputMode {
	KEYBOARD_MOUSE,
	GAMEPAD,
}
const GLOBAL_GLOW_INTENSITY := 0.92
const GLOBAL_GLOW_STRENGTH := 1.22
const GLOBAL_GLOW_BLOOM := 0.075
const GLOBAL_GLOW_HDR_THRESHOLD := 0.26
const GLOBAL_GLOW_HDR_SCALE := 2.55
const TUNNEL_GLOW_ALBEDO_DARKEN := 0.36
const TUNNEL_GLOW_RADIAL_ALBEDO_DARKEN := 0.48
const TUNNEL_GLOW_EMISSION_DARKEN := 0.24
const TUNNEL_GLOW_RADIAL_EMISSION_DARKEN := 0.38
const TUNNEL_GLOW_RING_ENERGY := 2.75
const TUNNEL_GLOW_RADIAL_ENERGY := 1.85
const SOFT_SHADOW_TINT := Color(0.018, 0.105, 0.120)
const SOFT_SHADOW_FEATHER := 1.52
const SOFT_SHADOW_CENTER_ALPHA := 0.92
const SOFT_SHADOW_INNER_ALPHA := 0.42
const ENEMY_PLATE_SHADOW_ALPHA := 0.22
const ENEMY_BATCH_PLATE_SHADOW_ALPHA := 0.24
const PLAYER_PLATE_SHADOW_ALPHA := 0.20
const TUNNEL_SHADOW_HEIGHT := 0.035
const TUNNEL_SHADOW_CENTER_SCALE := 0.36
const TUNNEL_SHADOW_EDGE_SCALE := 1.85
const SCANLINE_COUNT := 11
const SPAWN_EFFECT_TIME := 0.50
const PLAYER_EXTEND_VISUAL_HEIGHT := 1.05
const PLAYER_EXTEND_RENDER_PRIORITY := 12
const ENEMY_SPAWN_INVULN_TIME := 0.50
const DEFAULT_ENEMY_VISUAL_HEIGHT := 0.26
const MOVING_CHARACTER_VISUAL_HEIGHT := 0.72
const ZAKO5_VISUAL_SCALE := 0.58
const ZAKO7_VISUAL_SCALE := 0.68
const ZAKO7_CHAIN_SPACING := 0.65
const ZAKO7_CHAIN_DISTANCE_TOLERANCE := 0.20
const ZAKO7_CHAIN_TURN_SPEED := deg_to_rad(4.0 * 60.0)
const ZAKO7_CHAIN_SHARP_TURN_SPEED := deg_to_rad(10.0 * 60.0)
const ZAKO7_CHAIN_SHARP_TURN_THRESHOLD := deg_to_rad(10.0)
const ZAKO_GUN0_RECOIL_DISTANCE := 0.07
const ZAKO_GUN1_RECOIL_DISTANCE := 0.14
const ZAKO_GUN0_RECOIL_RECOVERY := 7.0
const ZAKO_GUN1_RECOIL_RECOVERY := 11.0
const ZAKO_GUN1_BURST_FIRST_SHOT := 2.0
const ZAKO_GUN1_BURST_PERIOD := 2.0
const ZAKO_GUN1_BURST_INTERVAL := 4.0 / 60.0
const ZAKO_GUN1_BURST_SHOT_COUNT := 5
const ZAKO1_VISUAL_SCALE := 0.85
const ZAKO1_VISUAL_ROLL_SPEED := 0.72
const ZAKO1_CROSS_SECTION_RADIUS := 0.28
const ZAKO0_VISUAL_MAX_BANK := deg_to_rad(60.0)
const ZAKO0_VISUAL_MAX_PITCH := deg_to_rad(20.0)
const ZAKO0_VISUAL_RESPONSE := 7.0
const ZAKO0_VISUAL_FULL_BANK_TURN_RATE := 0.75
const ZAKO2_VISUAL_MAX_BANK := deg_to_rad(44.0)
const ZAKO2_VISUAL_MAX_PITCH := deg_to_rad(18.0)
const ZAKO2_VISUAL_RESPONSE := 8.0
const ZAKO2_VISUAL_FULL_BANK_TURN_RATE := 5.8
const ZAKO2_BLADE_PITCH := deg_to_rad(13.0)
const ZAKO3P_VISUAL_MAX_BANK := deg_to_rad(42.0)
const ZAKO3P_VISUAL_MAX_PITCH := deg_to_rad(24.0)
const ZAKO3P_VISUAL_RESPONSE := 9.0
const ZAKO3P_VISUAL_FULL_BANK_TURN_RATE := 1.1
const ZAKO3P_VISUAL_ROLL_SPEED := 0.85
const ZAKO3P_VISUAL_SCALE := 1.35
const ZAKO_BASE_OUTLINE_WIDTH := 0.012
const ZAKO4_OUTLINE_WIDTH := ZAKO_BASE_OUTLINE_WIDTH
const ZAKO4_VISUAL_MAX_BANK := deg_to_rad(44.0)
const ZAKO4_VISUAL_MAX_PITCH := deg_to_rad(18.0)
const ZAKO4_VISUAL_RESPONSE := 7.0
const ZAKO4_VISUAL_FULL_BANK_TURN_RATE := 3.0
const ZAKO4_VISUAL_SPIN_SPEED := deg_to_rad(10.0 * 60.0)
const ZAKO5_VISUAL_MAX_BANK := deg_to_rad(55.0)
const ZAKO5_VISUAL_MAX_PITCH := deg_to_rad(22.0)
const ZAKO5_VISUAL_RESPONSE := 8.0
const ZAKO5_VISUAL_FULL_BANK_TURN_RATE := 0.75
const ZAKO5_LINE_BULLET_INTERVAL := 0.20
const ZAKO5_LINE_BULLET_LENGTH := 0.68
const ZAKO5_TURN_RATE := deg_to_rad(30.0)
const ZAKO6_OUTER_OUTLINE_WIDTH := ZAKO_BASE_OUTLINE_WIDTH
const ZAKO6_VISUAL_MAX_BANK := deg_to_rad(52.0)
const ZAKO6_VISUAL_MAX_PITCH := deg_to_rad(32.0)
const ZAKO6_VISUAL_RESPONSE := 8.0
const ZAKO6_VISUAL_FULL_BANK_TURN_RATE := 1.0
const ZAKO6_VISUAL_SPIN_SPEED := 8.0
const ZAKO7_VISUAL_MAX_BANK := deg_to_rad(60.0)
const ZAKO7_VISUAL_MAX_PITCH := deg_to_rad(22.0)
const ZAKO7_VISUAL_RESPONSE := 8.0
const ZAKO7_VISUAL_FULL_BANK_TURN_RATE := 0.9
const ZAKO7P_CHAIN_VISUAL_MAX_BANK := deg_to_rad(38.0)
const ZAKO7P_CHAIN_VISUAL_MAX_PITCH := deg_to_rad(20.0)
const ZAKO7P_RELEASED_VISUAL_MAX_BANK := deg_to_rad(50.0)
const ZAKO7P_RELEASED_VISUAL_MAX_PITCH := deg_to_rad(26.0)
const ZAKO7P_VISUAL_RESPONSE := 9.0
const ZAKO7P_VISUAL_FULL_BANK_TURN_RATE := 1.2
const ZAKO7P_CHAIN_VISUAL_ROLL_SPEED := 0.55
const ZAKO7P_RELEASED_VISUAL_ROLL_SPEED := 1.05
const ZAKOM1_OUTLINE_WIDTH := ZAKO_BASE_OUTLINE_WIDTH
const ZAKOM1_RIDGE_WIDTH := 0.014
const ZAKOM1_VISUAL_ROLL_SPEED := 0.82
const ZAKOM0_OUTWARD_TILT := deg_to_rad(13.0)
const BATCHED_ENEMY_KINDS := ["zako0", "zako1", "zako2", "zako3", "zako3p", "zako4", "zako5", "zako6", "zako7", "zako7p", "zakoM0", "zakoM1"]
const TITLE_MODES := [
	"ARCADE MODE",
	"ENDLESS NORMAL",
	"ENDLESS HARD",
	"ENDLESS INSANE",
	"INSANE VOID",
]
const TITLE_REGULAR_MODE_COUNT := 4
const TITLE_VOID_MODE_INDEX := 4
const TITLE_VOID_MENU_ROW := 6
const TITLE_DIVIDER_RATIO := 0.373
const MENU_ROW_HEIGHT := 14
const UI_SVG_SCALE := 4.0
const TITLE_VOID_SIDE_CROP := 4

var palette := {
	"bg": Color(0.025, 0.055, 0.075),
	"grid": Color(0.16, 0.45, 0.50, 0.35),
	"player": Color(0.32, 0.95, 0.86),
	"player_core": Color(1.00, 0.86, 0.35),
	"shot": Color(0.80, 0.95, 1.00),
	"gum": Color(0.96, 0.42, 0.78),
	"gum_low": Color(0.35, 0.42, 0.58),
	"gum_empty": Color(1.00, 0.22, 0.16),
	"zako0": Color(0.96, 0.28, 0.35),
	"zako1": Color(1.00, 0.62, 0.12),
	"zako2": Color(0.35, 0.86, 0.42),
	"zako3": Color(0.96, 0.16, 0.30),
	"zako3p": Color(1.00, 0.66, 0.12),
	"zako4": Color(1.00, 0.52, 0.18),
	"zako5": Color(1.00, 0.82, 0.25),
	"zako6": Color(0.42, 1.00, 0.72),
	"zako7": Color(0.95, 0.38, 1.00),
	"zako7p": Color(1.00, 0.66, 0.12),
	"zakoM0": Color(0.90, 0.92, 0.96),
	"zakoM1": Color(1.00, 0.66, 0.12),
	"boss_core": Color(0.30, 0.92, 1.00),
	"boss_turret": Color(1.00, 0.70, 0.20),
	"boss_turret_t1": Color(1.00, 0.70, 0.20),
	"boss_turret_t2": Color(1.00, 0.36, 0.20),
	"boss_turret_t3": Color(1.00, 0.66, 0.12),
	"boss_unblockable": Color(1.00, 0.08, 0.16),
}

var camera: Camera3D
var game_state := GameStateUtil.new()
var sfx: SfxPlayer
var bgm: BgmPlayer
var time_warp_audio
var player: Player
var gum_controller: GumController
var boss_gum_controller: BossGumController
var bullet_manager: BulletManager
var spawner := SpawnerUtil.new()
var boss := BossUtil.new()

var enemies: Array[Dictionary] = []
var enemy_flip := false
var enemy_visual_batch_root: Node3D
var enemy_visual_batches := {}
var chain_seq := 0
var game_time_scale := 1.0
var object_pressure := 0
var debug_collisions := false
var debug_root: Node3D
var debug_profile_timer := 0.0
var debug_profile_log_timer := 0.0
var debug_profile_text := ""
var tunnel_root: Node3D
var tunnel_ring_multimesh: MultiMesh
var tunnel_radial_multimesh: MultiMesh
var tunnel_stream_multimesh: MultiMesh
var tunnel_stream_material: Material
var tunnel_ring_material: StandardMaterial3D
var tunnel_radial_material: StandardMaterial3D
var floor_plane: MeshInstance3D
var floor_material: StandardMaterial3D
var main_light: DirectionalLight3D
var world_environment: WorldEnvironment
var tunnel_time := 0.0
var tunnel_speed := 1.0
var tunnel_density_stride := 1
var background_profile_key := ""
var background_light_base_energy := 2.2
var scanline_root: Node3D
var scanlines: Array[MeshInstance3D] = []
var scanline_time := 0.0
var aim_reticle: Node3D
var aim_reticle_sweep: Node3D
var aim_reticle_fire_blend := 0.0
var player_shadow: Node3D
var aim_reticle_timer := 0.0
var backfire_timer := 0.0
var player_spawn_effect_timer := 0.0
var title_layer: CanvasLayer
var title_shade: ColorRect
var title_band: ColorRect
var title_menu_buttons: Array[Button] = []
var title_hi_score: BitmapNumber
var title_mode_index := 0
var title_void_revealed := false
var title_void_noise_timer := 0.0
var title_accept_blocked_by_fullscreen := false
var arcade_clear_layer: CanvasLayer
var game_over_layer: CanvasLayer
var bullet_time_glitch: Control
var model_gallery: Node3D
var gallery_active := false
var input_mode := InputMode.KEYBOARD_MOUSE
var active_joypad_device := 0
var app_has_focus := true
var web_right_mouse_down := false
var web_pointer_callback
var web_context_menu_callback

var hud: GameHud


func _ready() -> void:
	_setup_gamepad_input()
	_apply_input_mode(InputMode.KEYBOARD_MOUSE)
	RenderingServer.set_default_clear_color(palette.bg)
	_setup_camera()
	_setup_world_environment()
	_setup_light()
	_setup_floor()
	_setup_debug()
	_setup_time_warp_audio()
	_setup_sfx()
	_setup_bgm()
	_setup_bullets()
	_setup_enemy_visual_batches()
	_setup_player()
	_setup_player_shadow()
	_setup_aim_reticle()
	_setup_gum()
	_setup_boss_gum()
	_setup_web_mouse_input()
	_setup_hud()
	_setup_bullet_time_glitch()
	_setup_title()
	_setup_model_gallery()
	_setup_game_over()
	_setup_arcade_clear()
	_set_title_visible(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		app_has_focus = false
		_refresh_mouse_mode()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		app_has_focus = true
		_refresh_mouse_mode.call_deferred()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gamepad_back"):
		_handle_escape()
		return
	if Input.is_action_just_pressed("toggle_fullscreen"):
		_toggle_fullscreen()
	if _debug_shortcuts_enabled() and Input.is_action_just_pressed("toggle_debug_collisions"):
		debug_collisions = not debug_collisions

	_update_player_aim()
	_update_aim_reticle(delta)
	_update_background_tunnel(delta)
	if not game_state.game_started:
		_update_bullet_time_glitch(delta)
		if gallery_active:
			model_gallery.update_gallery(delta)
			_apply_gallery_background_visibility()
			_update_debug_collisions()
			return
		_update_title()
		_update_debug_collisions()
		return
	bullet_manager.set_game_context(game_state.game_mode, game_state.arcade_rank)
	if game_state.game_over:
		_update_game_over_scene(delta)
		_update_game_over()
		_update_debug_collisions()
		return
	if game_state.arcade_cleared:
		_update_arcade_clear_scene(delta)
		_update_arcade_clear()
		_update_debug_collisions()
		return
	bgm.sync(game_state.game_mode, game_state.endless_difficulty, game_state.music_stage)
	_update_game_timing(delta)
	_update_bullet_time_glitch(delta)
	var sim_delta := delta * game_time_scale
	game_state.update_tension(sim_delta)
	var was_player_alive := player.alive
	if player.update_life(delta, game_state.player_lives):
		_show_game_over()
		_update_debug_collisions()
		return
	if not was_player_alive and player.alive:
		player_spawn_effect_timer = SPAWN_EFFECT_TIME
		_spawn_player_respawn_effect(player.pos)
	if player.alive:
		player.update_motion(sim_delta, FIELD_W, FIELD_H, FIELD_EDGE_MARGIN)
		_refresh_gamepad_aim_anchor()
		_update_player_spawn_effect(sim_delta)
		_update_player_shadow()
		_update_player_backfire(sim_delta)
		gum_controller.update_controller(sim_delta, player.pos, player.angle, player.aim_pos, bullet_manager.bullets, enemies, bullet_manager.shape_for, _gamepad_gum_launch_bounds())
	else:
		player.visible = false
		_update_player_shadow()
		gum_controller.visible = false
	_update_boss_gum_attack(sim_delta, _player_can_be_hit())
	if bullet_manager.update_bullets(sim_delta, FIELD_W, FIELD_H, DESPAWN_MARGIN, _player_can_be_hit(), _player_hit_axis(), enemies):
		_kill_player()
	_update_enemies(sim_delta)
	if not game_state.arcade_cleared:
		_update_spawning(sim_delta)
	_update_enemy_visual_batches()
	bullet_manager.flush_visual_batches()
	_update_debug_collisions()
	_update_debug_profile(delta)
	_update_hud()


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_ESCAPE:
		_handle_escape()
		return
	if _debug_shortcuts_enabled() and key_event.keycode == KEY_G and not game_state.game_started:
		_set_gallery_active(not gallery_active)
		return
	if gallery_active and key_event.keycode in [KEY_LEFT, KEY_A]:
		model_gallery.change_category(-1)
		_apply_gallery_background_visibility()
		return
	if gallery_active and key_event.keycode in [KEY_RIGHT, KEY_D]:
		model_gallery.change_category(1)
		_apply_gallery_background_visibility()
		return
	if not _debug_shortcuts_enabled():
		return
	if key_event.keycode == KEY_F3:
		_debug_add_score()
	elif key_event.keycode == KEY_F4:
		_debug_next_rank()
	elif key_event.keycode == KEY_F5:
		_debug_cycle_mode()
	elif key_event.keycode == KEY_F6:
		_debug_force_boss()


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		active_joypad_device = event.device
		_apply_input_mode(InputMode.GAMEPAD)
	elif event is InputEventJoypadMotion and absf(event.axis_value) >= GAMEPAD_AIM_DEADZONE:
		active_joypad_device = event.device
		_apply_input_mode(InputMode.GAMEPAD)
	elif event is InputEventMouseButton and event.pressed:
		_apply_input_mode(InputMode.KEYBOARD_MOUSE)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_LEFT, KEY_DOWN, KEY_RIGHT]:
			_apply_input_mode(InputMode.KEYBOARD_MOUSE)


func _setup_gamepad_input() -> void:
	_ensure_input_action("gamepad_accept")
	_ensure_input_action("gamepad_back")
	_add_joy_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_add_joy_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_joy_button("move_up", JOY_BUTTON_DPAD_UP)
	_add_joy_button("move_down", JOY_BUTTON_DPAD_DOWN)
	_add_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_button("fire", JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_axis("fire", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_add_joy_button("gum", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_axis("gum", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_add_joy_button("gamepad_accept", JOY_BUTTON_A)
	_add_joy_button("gamepad_accept", JOY_BUTTON_START)
	_add_joy_button("gamepad_back", JOY_BUTTON_B)
	_add_joy_button("gamepad_back", JOY_BUTTON_BACK)


func _ensure_input_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.5)


func _add_joy_button(action: StringName, button: JoyButton) -> void:
	_ensure_input_action(action)
	var event := InputEventJoypadButton.new()
	event.button_index = button
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)


func _add_joy_axis(action: StringName, axis: JoyAxis, axis_value: float) -> void:
	_ensure_input_action(action)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)


func _apply_input_mode(mode: InputMode) -> void:
	input_mode = mode
	_refresh_mouse_mode()


func _refresh_mouse_mode() -> void:
	var window_mode := DisplayServer.window_get_mode()
	var fullscreen := window_mode in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	Input.mouse_mode = _desired_mouse_mode(fullscreen)


func _desired_mouse_mode(fullscreen: bool) -> Input.MouseMode:
	if not app_has_focus:
		return Input.MOUSE_MODE_VISIBLE
	if fullscreen:
		return Input.MOUSE_MODE_CONFINED if input_mode == InputMode.KEYBOARD_MOUSE else Input.MOUSE_MODE_CONFINED_HIDDEN
	return Input.MOUSE_MODE_VISIBLE if input_mode == InputMode.KEYBOARD_MOUSE else Input.MOUSE_MODE_HIDDEN


func _update_player_aim() -> void:
	if input_mode == InputMode.GAMEPAD:
		var direction := Vector2(
			Input.get_joy_axis(active_joypad_device, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(active_joypad_device, JOY_AXIS_RIGHT_Y)
		)
		if direction.length() >= GAMEPAD_AIM_DEADZONE:
			player.update_aim_direction(direction)
		_refresh_gamepad_aim_anchor()
	else:
		player.update_aim(camera, get_viewport().get_mouse_position())


func _refresh_gamepad_aim_anchor() -> void:
	if input_mode == InputMode.GAMEPAD:
		player.aim_pos = _gamepad_aim_point(player.pos, Vector2.from_angle(player.angle))


func _gamepad_aim_point(origin: Vector2, direction: Vector2) -> Vector2:
	var normalized_direction := direction.normalized()
	var distance_to_x := INF
	var distance_to_y := INF
	if absf(normalized_direction.x) > 0.0001:
		var edge_x := FIELD_W * 0.5 if normalized_direction.x > 0.0 else -FIELD_W * 0.5
		distance_to_x = (edge_x - origin.x) / normalized_direction.x
	if absf(normalized_direction.y) > 0.0001:
		var edge_y := FIELD_H * 0.5 if normalized_direction.y > 0.0 else -FIELD_H * 0.5
		distance_to_y = (edge_y - origin.y) / normalized_direction.y
	return origin + normalized_direction * minf(distance_to_x, distance_to_y)


func _gamepad_gum_launch_bounds() -> Rect2:
	if input_mode != InputMode.GAMEPAD:
		return Rect2()
	return Rect2(-FIELD_W * 0.5, -FIELD_H * 0.5, FIELD_W, FIELD_H)


func _accept_just_pressed() -> bool:
	return Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("gamepad_accept") or Input.is_key_pressed(KEY_ENTER)


func _debug_shortcuts_enabled() -> bool:
	return OS.is_debug_build()


func _setup_camera() -> void:
	camera = Camera3D.new()
	camera.name = "TopDownCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = FIELD_H
	camera.position = Vector3(0.0, 16.0, 0.01)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	add_child(camera)


func _setup_world_environment() -> void:
	world_environment = WorldEnvironment.new()
	world_environment.name = "GlobalGlowEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = palette.bg
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.03, 0.04, 0.05)
	environment.ambient_light_energy = 0.25
	environment.glow_enabled = GLOBAL_GLOW_ENABLED
	environment.glow_intensity = GLOBAL_GLOW_INTENSITY
	environment.glow_strength = GLOBAL_GLOW_STRENGTH
	environment.glow_bloom = GLOBAL_GLOW_BLOOM
	environment.glow_hdr_threshold = GLOBAL_GLOW_HDR_THRESHOLD
	environment.glow_hdr_scale = GLOBAL_GLOW_HDR_SCALE
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	world_environment.environment = environment
	add_child(world_environment)


func _setup_light() -> void:
	var light := DirectionalLight3D.new()
	light.name = "SoftMicroscopeLight"
	light.light_energy = 2.2
	light.rotation_degrees = BACKGROUND_LIGHT_BASE_ROTATION
	add_child(light)
	main_light = light


func _setup_floor() -> void:
	var plane := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(FIELD_W, FIELD_H)
	plane.mesh = mesh
	floor_material = _floor_material()
	plane.material_override = floor_material
	add_child(plane)
	floor_plane = plane

	_setup_background_tunnel()
	_setup_scanlines()


func _setup_background_tunnel() -> void:
	tunnel_root = Node3D.new()
	tunnel_root.name = "WireTunnelBackground"
	add_child(tunnel_root)

	var color := Color(0.26, 0.58, 0.72)
	tunnel_ring_material = _material(color.darkened(TUNNEL_GLOW_ALBEDO_DARKEN), color.darkened(TUNNEL_GLOW_EMISSION_DARKEN), TUNNEL_GLOW_RING_ENERGY)
	tunnel_radial_material = _material(color.darkened(TUNNEL_GLOW_RADIAL_ALBEDO_DARKEN), color.darkened(TUNNEL_GLOW_RADIAL_EMISSION_DARKEN), TUNNEL_GLOW_RADIAL_ENERGY)
	tunnel_ring_multimesh = _create_line_multimesh(TUNNEL_RING_COUNT * TUNNEL_SEGMENTS, tunnel_ring_material)
	tunnel_radial_multimesh = _create_line_multimesh((TUNNEL_RING_COUNT - 1) * TUNNEL_SEGMENTS, tunnel_radial_material)
	tunnel_stream_material = VisualMaterialsUtil.flat_face(Color(0.94, 0.98, 1.0), 0.09, 0.42)
	var stream_count := TUNNEL_STREAM_LANES * TUNNEL_STREAM_PLATES_PER_LANE if TUNNEL_STREAM_ENABLED else 0
	tunnel_stream_multimesh = _create_tunnel_stream_multimesh(stream_count, tunnel_stream_material)


func _create_line_multimesh(instance_count: int, material: Material) -> MultiMesh:
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instance_count
	multimesh.mesh = box
	multimesh.custom_aabb = AABB(Vector3(-40.0, -1.0, -40.0), Vector3(80.0, 2.0, 80.0))
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	instance.material_override = material
	tunnel_root.add_child(instance)
	return multimesh


func _create_tunnel_stream_multimesh(instance_count: int, material: Material) -> MultiMesh:
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instance_count
	multimesh.mesh = box
	multimesh.custom_aabb = AABB(Vector3(-40.0, -1.0, -40.0), Vector3(80.0, 2.0, 80.0))
	var instance := MultiMeshInstance3D.new()
	instance.name = "TunnelStreamPlates"
	instance.multimesh = multimesh
	instance.material_override = material
	tunnel_root.add_child(instance)
	return multimesh


func _setup_scanlines() -> void:
	scanline_root = Node3D.new()
	scanline_root.name = "RisingScanlines"
	add_child(scanline_root)
	scanlines.clear()
	for i in range(SCANLINE_COUNT):
		var line := _line_mesh(Vector2(-FIELD_W * 0.5, 0.0), Vector2(FIELD_W * 0.5, 0.0), 0.008, palette.grid.darkened(0.25))
		scanline_root.add_child(line)
		scanlines.append(line)


func _update_background_tunnel(delta: float) -> void:
	_update_background_profile()
	tunnel_time += delta * tunnel_speed
	_update_background_light()
	scanline_time += delta * (0.10 + tunnel_speed * 0.035)
	_update_scanlines()
	_update_tunnel_stream_plates()
	var ring_index := 0
	var radial_index := 0
	for ring in range(TUNNEL_RING_COUNT):
		for segment in range(TUNNEL_SEGMENTS):
			var a := _tunnel_point(ring, segment)
			var b := _tunnel_point(ring, (segment + 1) % TUNNEL_SEGMENTS)
			tunnel_ring_multimesh.set_instance_transform(ring_index, _line_transform(a, b, _tunnel_line_width(_tunnel_depth(ring), false)))
			ring_index += 1
			if ring >= TUNNEL_RING_COUNT - 1:
				continue
			var depth := _tunnel_depth(ring)
			var next_depth := _tunnel_depth(ring + 1)
			if segment % tunnel_density_stride != 0 or next_depth <= depth:
				tunnel_radial_multimesh.set_instance_transform(radial_index, Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))
				radial_index += 1
				continue
			var radial_b := _tunnel_point(ring + 1, segment)
			tunnel_radial_multimesh.set_instance_transform(radial_index, _line_transform(a, radial_b, _tunnel_line_width((depth + next_depth) * 0.5, true)))
			radial_index += 1


func _update_tunnel_stream_plates() -> void:
	if not TUNNEL_STREAM_ENABLED or tunnel_stream_multimesh == null:
		return
	var instance_index := 0
	for lane in range(TUNNEL_STREAM_LANES):
		var lane_phase := float(lane) / float(TUNNEL_STREAM_LANES)
		var scroll_phase := tunnel_time * TUNNEL_STREAM_SPEED / float(TUNNEL_RING_COUNT) + lane_phase * 0.053
		for plate in range(TUNNEL_STREAM_PLATES_PER_LANE):
			var plate_phase := fposmod(float(plate) / float(TUNNEL_STREAM_PLATES_PER_LANE) + scroll_phase, 1.0)
			var depth := _tunnel_stream_depth_from_phase(plate_phase)
			var transform := _tunnel_stream_plate_transform(depth, lane, plate, plate_phase)
			tunnel_stream_multimesh.set_instance_transform(instance_index, transform)
			instance_index += 1


func _tunnel_stream_depth_from_phase(phase: float) -> float:
	return pow(clampf(phase, 0.0, 1.0), 2.30) * (float(TUNNEL_RING_COUNT) - 0.001)


func _tunnel_stream_plate_transform(depth: float, lane: int, plate: int, plate_phase: float) -> Transform3D:
	var normalized_depth := clampf(depth / float(TUNNEL_RING_COUNT - 1), 0.0, 1.0)
	var pos := _tunnel_stream_plate_position(depth, lane, plate)
	var max_depth := float(TUNNEL_RING_COUNT) - 0.001
	var sample_depth := 0.18
	var previous_pos := _tunnel_stream_plate_position(maxf(0.0, depth - sample_depth), lane, plate)
	var next_pos := _tunnel_stream_plate_position(minf(max_depth, depth + sample_depth), lane, plate)
	var travel := next_pos - previous_pos
	if travel.is_zero_approx():
		travel = Vector2.RIGHT
	var direction := travel.normalized()
	var before_direction := (pos - previous_pos).normalized()
	var after_direction := (next_pos - pos).normalized()
	var straightness := clampf((before_direction.dot(after_direction) + 1.0) * 0.5, 0.0, 1.0)
	var curve_length_factor := lerpf(0.52, 1.0, pow(straightness, 0.45))
	var interval_length := _tunnel_stream_neighbor_interval(pos, lane, plate, plate_phase)
	var base_length := lerpf(0.08, 2.10, pow(normalized_depth, 1.35)) * curve_length_factor
	var length := minf(base_length, interval_length * 0.55)
	var width := lerpf(0.036, 0.290, pow(normalized_depth, 1.15))
	var wall_side_2d := _tunnel_stream_wall_side(depth, lane)
	var side_blend := wall_side_2d.lerp(Vector2(-direction.y, direction.x), 0.28).normalized()
	var side := Vector3(side_blend.x, 0.0, side_blend.y) * width
	var up := Vector3.UP * 0.010
	var forward := Vector3(direction.x, 0.0, direction.y) * length
	var basis := Basis(side, up, forward)
	return Transform3D(basis, _to_world(pos, TUNNEL_STREAM_HEIGHT))


func _tunnel_stream_neighbor_interval(pos: Vector2, lane: int, plate: int, plate_phase: float) -> float:
	var phase_step := 1.0 / float(TUNNEL_STREAM_PLATES_PER_LANE)
	var interval := INF
	if plate_phase >= phase_step:
		var previous_depth := _tunnel_stream_depth_from_phase(plate_phase - phase_step)
		interval = minf(interval, pos.distance_to(_tunnel_stream_plate_position(previous_depth, lane, plate)))
	if plate_phase <= 1.0 - phase_step:
		var next_depth := _tunnel_stream_depth_from_phase(plate_phase + phase_step)
		interval = minf(interval, pos.distance_to(_tunnel_stream_plate_position(next_depth, lane, plate)))
	if is_inf(interval):
		return 1.0
	return maxf(interval, 0.12)


func _tunnel_stream_wall_side(depth: float, lane: int) -> Vector2:
	var angle_step := 0.022
	var normalized_depth := clampf(depth / float(TUNNEL_RING_COUNT - 1), 0.0, 1.0)
	var center := _tunnel_center_at(normalized_depth)
	var perspective := pow(normalized_depth, 2.80)
	var radius := lerpf(TUNNEL_FAR_RADIUS, TUNNEL_NEAR_RADIUS, perspective)
	var lane_t := float(lane) / float(TUNNEL_STREAM_LANES)
	var lane_curve := sin(normalized_depth * PI * 1.15 + float(lane) * 1.71 + tunnel_time * 0.30) * 0.30
	lane_curve += sin(normalized_depth * TAU * 0.42 + float(lane) * 0.83 - tunnel_time * 0.17) * 0.10
	var angle := lane_t * TAU + lane_curve
	var squash := 0.58 + sin(tunnel_time * 0.29 + depth * 0.14) * 0.12
	var float_out := lerpf(0.16, 0.72, pow(normalized_depth, 0.82))
	var before := center + Vector2(cos(angle - angle_step) * (radius + float_out), sin(angle - angle_step) * (radius + float_out) * squash)
	var after := center + Vector2(cos(angle + angle_step) * (radius + float_out), sin(angle + angle_step) * (radius + float_out) * squash)
	var side := after - before
	if side.is_zero_approx():
		return Vector2.RIGHT
	return side.normalized()


func _tunnel_stream_plate_position(depth: float, lane: int, _plate: int) -> Vector2:
	var normalized_depth := clampf(depth / float(TUNNEL_RING_COUNT - 1), 0.0, 1.0)
	var center := _tunnel_center_at(normalized_depth)
	var perspective := pow(normalized_depth, 2.80)
	var radius := lerpf(TUNNEL_FAR_RADIUS, TUNNEL_NEAR_RADIUS, perspective)
	var lane_t := float(lane) / float(TUNNEL_STREAM_LANES)
	var lane_curve := sin(normalized_depth * PI * 1.15 + float(lane) * 1.71 + tunnel_time * 0.30) * 0.30
	lane_curve += sin(normalized_depth * TAU * 0.42 + float(lane) * 0.83 - tunnel_time * 0.17) * 0.10
	var angle := lane_t * TAU + lane_curve
	var squash := 0.58 + sin(tunnel_time * 0.29 + depth * 0.14) * 0.12
	var float_out := lerpf(0.16, 0.72, pow(normalized_depth, 0.82))
	return center + Vector2(cos(angle) * (radius + float_out), sin(angle) * (radius + float_out) * squash)


func _update_scanlines() -> void:
	for i in range(scanlines.size()):
		var phase := fmod(scanline_time + float(i) / float(scanlines.size()), 1.0)
		var y := lerpf(FIELD_H * 0.52, -FIELD_H * 0.52, pow(phase, 2.15))
		var width := lerpf(0.004, 0.008, phase)
		_set_line_mesh(scanlines[i], Vector2(-FIELD_W * 0.5, y), Vector2(FIELD_W * 0.5, y), width)


func _update_background_profile() -> void:
	var profile_key := "title"
	if game_state.game_started:
		profile_key = "%s-%d" % [game_state.game_mode, game_state.endless_difficulty if game_state.game_mode == "endless" else game_state.music_stage]
	if profile_key == background_profile_key:
		return
	background_profile_key = profile_key

	var profile := _background_profile()
	var wire_color := _limit_tunnel_line_luminance(profile.wire)
	var bg_color: Color = profile.bg
	tunnel_speed = profile.speed
	tunnel_density_stride = profile.density_stride
	RenderingServer.set_default_clear_color(bg_color)
	background_light_base_energy = float(profile.get("light", _background_light_energy(bg_color)))
	_update_background_light()
	tunnel_ring_material.albedo_color = wire_color.darkened(TUNNEL_GLOW_ALBEDO_DARKEN)
	tunnel_ring_material.emission = wire_color.darkened(TUNNEL_GLOW_EMISSION_DARKEN)
	tunnel_ring_material.emission_energy_multiplier = TUNNEL_GLOW_RING_ENERGY
	var radial_color := wire_color.darkened(0.18)
	tunnel_radial_material.albedo_color = wire_color.darkened(TUNNEL_GLOW_RADIAL_ALBEDO_DARKEN)
	tunnel_radial_material.emission = radial_color.darkened(TUNNEL_GLOW_RADIAL_EMISSION_DARKEN)
	tunnel_radial_material.emission_energy_multiplier = TUNNEL_GLOW_RADIAL_ENERGY


func _limit_tunnel_line_luminance(color: Color) -> Color:
	var luminance := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
	if luminance <= TUNNEL_WIRE_MAX_LUMINANCE:
		return color
	var scale := TUNNEL_WIRE_MAX_LUMINANCE / luminance
	return Color(color.r * scale, color.g * scale, color.b * scale, color.a)

func _background_profile() -> Dictionary:
	if not game_state.game_started:
		return {"wire": Color(0.26, 0.58, 0.72), "bg": palette.bg, "speed": 1.0, "density_stride": 2, "light": 2.2}
	if game_state.game_mode == "endless":
		if game_state.endless_difficulty == 1:
			return {"wire": Color(0.86, 0.90, 0.92), "bg": Color(0.055, 0.060, 0.065), "speed": 1.30, "density_stride": 1, "light": 1.55}
		if game_state.endless_difficulty == 2:
			return {"wire": Color(0.58, 0.64, 0.72), "bg": Color(0.025, 0.028, 0.040), "speed": 1.45, "density_stride": 1, "light": 1.15}
		if game_state.endless_difficulty == 3:
			return {"wire": Color(0.48, 0.36, 0.70), "bg": Color(0.004, 0.004, 0.008), "speed": 1.65, "density_stride": 1, "light": 0.58}
		return {"wire": Color(1.00, 0.24, 0.38), "bg": Color(0.035, 0.005, 0.012), "speed": 1.85, "density_stride": 1, "light": 0.78}
	if game_state.music_stage == 1:
		return {"wire": Color(0.98, 0.46, 0.56), "bg": Color(0.078, 0.026, 0.044), "speed": 0.85, "density_stride": 2, "light": 2.2}
	if game_state.music_stage == 2:
		return {"wire": Color(0.12, 0.82, 0.74), "bg": Color(0.006, 0.040, 0.070), "speed": 1.08, "density_stride": 1, "light": 1.35}
	return {"wire": Color(0.20, 0.48, 1.00), "bg": Color(0.003, 0.009, 0.040), "speed": 1.35, "density_stride": 1, "light": 0.62}


func _tunnel_point(ring: int, segment: int) -> Vector2:
	var depth := _tunnel_depth(ring)
	var normalized_depth := depth / float(TUNNEL_RING_COUNT - 1)
	var perspective := pow(normalized_depth, 2.80)
	var radius := lerpf(TUNNEL_FAR_RADIUS, TUNNEL_NEAR_RADIUS, perspective)
	var segment_t := float(segment) / float(TUNNEL_SEGMENTS)
	var twist_rate := 0.30 + sin(tunnel_time * 0.19) * 0.18
	var twist := depth * twist_rate + tunnel_time * 0.72
	var angle := segment_t * TAU + twist + sin(tunnel_time * 0.31 + depth * 0.23) * 0.55
	var center := _tunnel_center_at(normalized_depth)
	var squash := 0.58 + sin(tunnel_time * 0.29 + depth * 0.14) * 0.12
	return center + Vector2(cos(angle) * radius, sin(angle) * radius * squash)


func _tunnel_center_at(normalized_depth: float) -> Vector2:
	var far_origin := Vector2(
		sin(tunnel_time * 0.23) * 2.15 + sin(tunnel_time * 0.071) * 0.85,
		cos(tunnel_time * 0.19) * 1.30 + sin(tunnel_time * 0.083) * 0.55
	)
	var curve_strength := Vector2(
		3.40 + sin(tunnel_time * 0.13) * 1.65,
		2.25 + cos(tunnel_time * 0.11) * 1.10
	)
	var curve := Vector2(
		sin(tunnel_time * 0.17 + normalized_depth * 5.1)
			+ sin(tunnel_time * 0.07 - normalized_depth * 10.4) * 0.48,
		cos(tunnel_time * 0.14 + normalized_depth * 4.4)
			+ sin(tunnel_time * 0.09 + normalized_depth * 8.8) * 0.44
	) * curve_strength * pow(normalized_depth, 0.58)
	return far_origin + curve


func _tunnel_shadow_projection(logical_pos: Vector2, visual_yaw: float) -> Dictionary:
	var field_half_diagonal := Vector2(FIELD_W * 0.5, FIELD_H * 0.5).length()
	var distance_t := clampf(logical_pos.length() / field_half_diagonal, 0.0, 1.0)
	var depth_t := clampf(0.34 + pow(distance_t, 0.75) * 0.42, 0.18, 0.88)
	var tunnel_center := _tunnel_center_at(depth_t)
	var projected_pos := logical_pos
	var radial := projected_pos - tunnel_center
	var radial_t := clampf(radial.length() / field_half_diagonal, 0.0, 1.0)
	var funnel_scale := lerpf(TUNNEL_SHADOW_CENTER_SCALE, TUNNEL_SHADOW_EDGE_SCALE, pow(radial_t, 0.72))
	return {
		"pos": projected_pos,
		"yaw": visual_yaw,
		"scale": Vector3(funnel_scale * lerpf(0.96, 1.08, distance_t), 1.0, funnel_scale * lerpf(1.02, 0.92, distance_t)),
	}


func _tunnel_shadow_transform(logical_pos: Vector2, visual_yaw: float, visual_scale: Vector3) -> Transform3D:
	var projection := _tunnel_shadow_projection(logical_pos, visual_yaw)
	var shadow_scale := visual_scale * 0.4
	var projection_scale: Vector3 = projection["scale"]
	var projected_pos: Vector2 = projection["pos"]
	shadow_scale.x *= projection_scale.x
	shadow_scale.z *= projection_scale.z
	var basis := Basis(Vector3.UP, float(projection["yaw"])).scaled(shadow_scale)
	return Transform3D(basis, _to_world(projected_pos, TUNNEL_SHADOW_HEIGHT))


func _yaw_from_direction(direction: Vector2) -> float:
	return -direction.angle() + PI * 0.5


func _tunnel_depth(ring: int) -> float:
	return fmod(float(ring) + tunnel_time * 2.45, float(TUNNEL_RING_COUNT))


func _tunnel_line_width(depth: float, radial: bool) -> float:
	var normalized_depth := clampf(depth / float(TUNNEL_RING_COUNT - 1), 0.0, 1.0)
	var near_width := 0.010 if radial else 0.012
	return lerpf(0.0015, near_width, pow(normalized_depth, 0.65))


func _line_transform(a: Vector2, b: Vector2, width: float) -> Transform3D:
	var mid := (a + b) * 0.5
	var dir := b - a
	var line_rotation := -dir.angle() + PI * 0.5
	var line_basis := Basis(Vector3.UP, line_rotation) * Basis.from_scale(Vector3(width, width, maxf(0.01, dir.length())))
	return Transform3D(line_basis, _to_world(mid, TUNNEL_VISUAL_HEIGHT))


func _setup_player() -> void:
	player = PlayerUtil.new()
	player.setup(palette)
	player.shot_requested.connect(_spawn_player_shot)
	add_child(player)


func _spawn_player_shot(pos: Vector2, angle: float) -> void:
	bullet_manager.spawn_player_shot(pos, angle)
	sfx.play("shot")


func _setup_player_shadow() -> void:
	player_shadow = null


func _update_player_shadow() -> void:
	if player_shadow == null or not is_instance_valid(player_shadow):
		return
	player_shadow.visible = game_state.game_started and player.alive
	player_shadow.transform = _tunnel_shadow_transform(player.pos, player.rotation.y, player.scale)


func _set_player_shadow_visible(value: bool) -> void:
	if player_shadow != null and is_instance_valid(player_shadow):
		player_shadow.visible = value


func _setup_aim_reticle() -> void:
	aim_reticle = Node3D.new()
	aim_reticle.name = "AimReticle"
	aim_reticle.add_child(_mousetarget_reticle_model(palette.player_core))
	aim_reticle_sweep = aim_reticle.find_child("mousetarget-visibility-sweep", true, false) as Node3D
	add_child(aim_reticle)
	_update_aim_reticle(0.0)


func _update_aim_reticle(delta: float) -> void:
	if aim_reticle == null:
		return
	aim_reticle.visible = input_mode == InputMode.KEYBOARD_MOUSE and game_state.game_started and not game_state.arcade_cleared and not game_state.game_over
	aim_reticle.position = _to_world(player.aim_pos, 0.10)
	aim_reticle_timer += delta
	aim_reticle.rotation.y = 0.0
	var pulse := 1.0 + sin(aim_reticle_timer * TAU * 2.0) * 0.055
	aim_reticle.scale = Vector3.ONE * pulse
	var firing := Input.is_action_pressed("fire")
	var target_blend := 1.0 if firing else 0.0
	aim_reticle_fire_blend = move_toward(aim_reticle_fire_blend, target_blend, delta * 7.5)
	_apply_mousetarget_reticle_state(aim_reticle, aim_reticle_fire_blend)
	if aim_reticle_sweep != null:
		var sweep_speed := 15.0 if firing else 8.0
		aim_reticle_sweep.rotate_y(delta * sweep_speed)


func _setup_bullets() -> void:
	bullet_manager = BulletManagerUtil.new()
	bullet_manager.setup(palette)
	bullet_manager.hit_effect_requested.connect(_spawn_hit_effect)
	add_child(bullet_manager)


func _setup_enemy_visual_batches() -> void:
	enemy_visual_batch_root = Node3D.new()
	enemy_visual_batch_root.name = "EnemyVisualBatches"
	add_child(enemy_visual_batch_root)


func _setup_gum() -> void:
	gum_controller = GumControllerUtil.new()
	gum_controller.setup(palette)
	gum_controller.hit_effect_requested.connect(_spawn_hit_effect)
	gum_controller.opened.connect(_play_gum_open)
	gum_controller.launched.connect(_play_gum_close)
	add_child(gum_controller)


func _setup_boss_gum() -> void:
	boss_gum_controller = BossGumControllerUtil.new()
	boss_gum_controller.setup(gum_controller)
	boss_gum_controller.hit_effect_requested.connect(_spawn_hit_effect)
	add_child(boss_gum_controller)


func _setup_web_mouse_input() -> void:
	if not OS.has_feature("web"):
		return
	var document = JavaScriptBridge.get_interface("document")
	var canvas = document.querySelector("canvas")
	if canvas == null:
		return
	web_pointer_callback = JavaScriptBridge.create_callback(_on_web_pointer_event)
	web_context_menu_callback = JavaScriptBridge.create_callback(_on_web_context_menu)
	for event_name in ["pointerdown", "pointerup", "pointermove", "pointercancel"]:
		canvas.addEventListener(event_name, web_pointer_callback, true)
	canvas.addEventListener("contextmenu", web_context_menu_callback, true)


func _on_web_pointer_event(args: Array) -> void:
	if args.is_empty():
		return
	var event = args[0]
	var button := int(event.button)
	var buttons := int(event.buttons)
	if button == 2 or (buttons & 2) != 0:
		event.preventDefault()
	_handle_web_pointer_state(String(event.type), button, buttons)


func _on_web_context_menu(args: Array) -> void:
	if not args.is_empty():
		args[0].preventDefault()


func _handle_web_pointer_state(event_type: String, button: int, buttons: int) -> bool:
	var secondary_down := (buttons & 2) != 0
	if event_type in ["pointerdown", "pointermove"] and secondary_down:
		if web_right_mouse_down:
			return false
		web_right_mouse_down = true
		_apply_input_mode(InputMode.KEYBOARD_MOUSE)
		gum_controller.request_input()
		return true
	if event_type in ["pointerup", "pointercancel"] and (button == 2 or not secondary_down):
		web_right_mouse_down = false
	return false


func _setup_sfx() -> void:
	sfx = SfxPlayerUtil.new()
	sfx.setup()
	add_child(sfx)
	game_state.score_extend_granted.connect(_play_extend)


func _setup_time_warp_audio() -> void:
	time_warp_audio = TimeWarpAudioUtil.new()
	time_warp_audio.name = "TimeWarpAudio"
	add_child(time_warp_audio)
	time_warp_audio.setup()


func _setup_bgm() -> void:
	bgm = BgmPlayerUtil.new()
	bgm.setup()
	add_child(bgm)


func _play_gum_open() -> void:
	sfx.play("gum_o")


func _play_gum_close() -> void:
	sfx.play("gum_c")


func _play_extend() -> void:
	sfx.play("extend")
	_spawn_player_extend_effect(player.pos)


func _setup_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	hud = GameHudUtil.new()
	layer.add_child(hud)
	hud.setup()


func _setup_bullet_time_glitch() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 1
	add_child(layer)
	bullet_time_glitch = BulletTimeGlitchUtil.new()
	layer.add_child(bullet_time_glitch)
	bullet_time_glitch.visible = false


func _setup_title() -> void:
	title_layer = CanvasLayer.new()
	title_layer.name = "TitleLayer"
	add_child(title_layer)

	title_shade = ColorRect.new()
	title_shade.name = "TitleShade"
	title_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_layer.add_child(title_shade)

	title_band = ColorRect.new()
	title_band.name = "TitleBand"
	title_band.anchor_right = TITLE_DIVIDER_RATIO
	title_band.anchor_bottom = 1.0
	title_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_layer.add_child(title_band)

	var divider := ColorRect.new()
	divider.name = "TitleDivider"
	divider.anchor_left = TITLE_DIVIDER_RATIO
	divider.anchor_right = TITLE_DIVIDER_RATIO
	divider.anchor_bottom = 1.0
	divider.offset_left = -1.0
	divider.offset_right = 1.0
	divider.color = Color(0.72, 0.70, 0.71, 0.55)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_layer.add_child(divider)

	var title := TextureRect.new()
	title.name = "TitleLogo"
	title.texture = TITLE_ATLAS
	title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# The logo is enlarged across the viewport; linear filtering keeps the V-shaped diagonals clean.
	title.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	title.anchor_left = 0.10
	title.anchor_top = 0.42
	title.anchor_right = 0.90
	title.anchor_bottom = 0.58
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_layer.add_child(title)

	var menu_root := VBoxContainer.new()
	menu_root.name = "TitleMenu"
	menu_root.anchor_left = 0.58
	menu_root.anchor_top = 0.72
	menu_root.anchor_right = 0.94
	menu_root.anchor_bottom = 0.94
	menu_root.add_theme_constant_override("separation", 0)
	title_layer.add_child(menu_root)
	title_menu_buttons.clear()
	for index in range(TITLE_MODES.size()):
		var button := Button.new()
		button.name = "Mode%d" % index
		button.icon = _menu_row_texture(TITLE_VOID_MENU_ROW if index == TITLE_VOID_MODE_INDEX else index, index == TITLE_VOID_MODE_INDEX)
		button.flat = true
		button.expand_icon = true
		button.focus_mode = Control.FOCUS_NONE
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(340.0, 30.0)
		button.pressed.connect(_start_title_mode.bind(index))
		menu_root.add_child(button)
		title_menu_buttons.append(button)

	title_hi_score = BitmapNumberUtil.new()
	title_hi_score.name = "TitleHiScore"
	title_hi_score.setup(SCORE_ATLAS, Vector2i(30, 16), 30, 26, GameHudUtil.NUMBER_SCALE)
	title_hi_score.set_number(int(game_state.hi_score), 9, 9)
	title_hi_score.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	title_hi_score.offset_left = -GameHudUtil.HUD_MARGIN - title_hi_score.size.x
	title_hi_score.offset_right = -GameHudUtil.HUD_MARGIN
	title_hi_score.offset_top = -GameHudUtil.HUD_MARGIN - title_hi_score.size.y
	title_hi_score.offset_bottom = -GameHudUtil.HUD_MARGIN
	title_layer.add_child(title_hi_score)

	var fullscreen_button := Button.new()
	fullscreen_button.name = "FullscreenButton"
	fullscreen_button.icon = _fullscreen_icon_texture()
	fullscreen_button.flat = true
	fullscreen_button.focus_mode = Control.FOCUS_NONE
	fullscreen_button.tooltip_text = "Fullscreen"
	fullscreen_button.anchor_left = 0.968
	fullscreen_button.anchor_right = 0.968
	fullscreen_button.anchor_top = 0.032
	fullscreen_button.anchor_bottom = 0.032
	fullscreen_button.offset_left = -13.5
	fullscreen_button.offset_right = 13.5
	fullscreen_button.offset_top = -13.5
	fullscreen_button.offset_bottom = 13.5
	fullscreen_button.button_down.connect(_block_title_accept_for_fullscreen)
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	title_layer.add_child(fullscreen_button)
	_refresh_title_menu()


func _set_title_visible(value: bool) -> void:
	if title_layer != null:
		title_layer.visible = value
	if value and is_instance_valid(title_hi_score):
		title_hi_score.set_number(int(game_state.hi_score), 9, 9)
	hud.visible = not value
	player.visible = not value
	gum_controller.visible = not value
	aim_reticle.visible = not value
	_set_player_shadow_visible(not value)


func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_mouse_mode.call_deferred()


func _block_title_accept_for_fullscreen() -> void:
	title_accept_blocked_by_fullscreen = true


func _fullscreen_icon_texture() -> Texture2D:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var color := Color(1.0, 1.0, 1.0, 0.48)
	_draw_icon_line(image, Vector2i(7, 7), Vector2i(13, 7), color)
	_draw_icon_line(image, Vector2i(7, 7), Vector2i(7, 13), color)
	_draw_icon_line(image, Vector2i(19, 7), Vector2i(25, 7), color)
	_draw_icon_line(image, Vector2i(25, 7), Vector2i(25, 13), color)
	_draw_icon_line(image, Vector2i(7, 19), Vector2i(7, 25), color)
	_draw_icon_line(image, Vector2i(7, 25), Vector2i(13, 25), color)
	_draw_icon_line(image, Vector2i(25, 19), Vector2i(25, 25), color)
	_draw_icon_line(image, Vector2i(19, 25), Vector2i(25, 25), color)
	return ImageTexture.create_from_image(image)


func _draw_icon_line(image: Image, from: Vector2i, to: Vector2i, color: Color) -> void:
	var delta := to - from
	var steps := maxi(abs(delta.x), abs(delta.y))
	for step in range(steps + 1):
		var t := 0.0 if steps == 0 else float(step) / float(steps)
		var point := Vector2i(roundi(lerpf(float(from.x), float(to.x), t)), roundi(lerpf(float(from.y), float(to.y), t)))
		for y in range(-1, 2):
			for x in range(-1, 2):
				var pixel := point + Vector2i(x, y)
				if pixel.x >= 0 and pixel.y >= 0 and pixel.x < image.get_width() and pixel.y < image.get_height():
					image.set_pixelv(pixel, color)


func _setup_model_gallery() -> void:
	model_gallery = ModelGalleryUtil.new()
	model_gallery.name = "ModelGallery"
	model_gallery.set_adopted_builders(_gameplay_gallery_builders())
	add_child(model_gallery)


func _gameplay_gallery_builders() -> Dictionary:
	var gum_model := (gum_controller.get_child(0) as Node3D).duplicate() as Node3D
	var player_model := player.visual_model.duplicate() as Node3D
	var player_capture_model := player.visual_model.duplicate() as Node3D
	var gallery_zakom0_color: Color = ModelGalleryUtil.ZAKOM0_COLOR
	var zakom0_model := _zako_m0_lattice_keep_model(gallery_zakom0_color)
	var square_gun := _zako_m0_square_gun(gallery_zakom0_color.lightened(0.10))
	square_gun.position = Vector3(-0.72, 0.30, 0.0)
	var sniper_gun := _zako_m0_prism_sniper(gallery_zakom0_color)
	sniper_gun.position = Vector3(0.55, 0.30, 0.0)
	zakom0_model.add_child(square_gun)
	zakom0_model.add_child(sniper_gun)
	return {
		"0:2": _gallery_model_builder(_zako0_dihedral_model(palette.zako0)),
		"1:0": _gallery_model_builder(_zako1_thin_wedge_model(palette.zako1), ZAKO1_VISUAL_SCALE),
		"2:2": _gallery_model_builder(_zako2_fan_blocks_model(palette.zako2)),
		"3:1": _gallery_model_builder(bullet_manager._bullet0_rugby_spindle()),
		"4:2": _gallery_model_builder(zakom0_model),
		"5:2": _gallery_model_builder(bullet_manager._bullet1_low_prism()),
		"6:2": _gallery_model_builder(_zako3_split_pod_model(palette.zako3, palette.zako3p)),
		"7:1": _gallery_model_builder(_zako3p_low_wedge_model(palette.zako3p), ZAKO3P_VISUAL_SCALE),
		"8:1": _gallery_model_builder(_zako4_diamond_battery_model(palette.zako4)),
		"9:1": _gallery_model_builder(bullet_manager._bullet2_low_prism()),
		"10:2": _gallery_model_builder(_zako5_armored_ray_model(palette.zako5), ZAKO5_VISUAL_SCALE),
		"11:2": _gallery_model_builder(_zako_m1_ridged_crystal_model(palette.zakoM1)),
		"12:2": _gallery_model_builder(_zako6_tilted_orbits_model(palette.zako6)),
		"13:1": _gallery_model_builder(_zako7_deep_v_glider_model(palette.zako7), ZAKO7_VISUAL_SCALE),
		"14:0": _gallery_model_builder(_zako7p_mini_crystal_model(palette.zako7p)),
		"15:2": _gallery_model_builder(bullet_manager._bullet3_low_rail(BulletManagerUtil.ZAKO_LINE_BULLET_LENGTH)),
		"16:1": _gallery_model_builder(bullet_manager._boss_b1_additive_rect(BulletManagerUtil.BOSS_B1_INITIAL_LENGTH)),
		"17:1": _gallery_model_builder(_boss_core_caged_model(palette.boss_core), BOSS_CORE_VISUAL_SCALE),
		"19:0": _gallery_model_builder(bullet_manager._player_shot_wireframe(palette.shot)),
		"20:0": _gallery_model_builder(_mousetarget_reticle_model(palette.player_core)),
		"21:0": _gallery_model_builder(gum_model),
		"22:2": _gallery_model_builder(player_model),
		"23:0": _gallery_model_builder(_boss_connection_ribbon_trial_model(0)),
		"23:1": _gallery_model_builder(_boss_connection_ribbon_trial_model(1)),
		"23:2": _gallery_model_builder(_boss_connection_ribbon_trial_model(2)),
		"24:0": _gallery_model_builder(player_capture_model),
	}


func _gallery_model_builder(model: Node3D, visual_scale := 1.0) -> Callable:
	model.position = Vector3.ZERO
	model.rotation = Vector3.ZERO
	model.scale = Vector3.ONE * visual_scale
	return func(root: Node3D) -> void:
		root.add_child(model)


func _set_gallery_active(value: bool) -> void:
	gallery_active = value
	model_gallery.set_active(value)
	title_layer.visible = not value
	hud.visible = false
	player.visible = not value
	gum_controller.visible = not value
	aim_reticle.visible = not value
	_set_player_shadow_visible(not value)
	_apply_gallery_background_visibility()


func _apply_gallery_background_visibility() -> void:
	var gallery := model_gallery as ModelGalleryUtil
	var show_background: bool = not gallery_active or gallery == null or not gallery.wants_clean_background()
	if tunnel_root != null:
		tunnel_root.visible = show_background
	if scanline_root != null:
		scanline_root.visible = show_background


func _setup_game_over() -> void:
	game_over_layer = _create_result_layer("GameOver", 4)


func _setup_arcade_clear() -> void:
	arcade_clear_layer = _create_result_layer("ArcadeClear", 5)


func _create_result_layer(layer_name: String, menu_row: int) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.name = layer_name
	layer.layer = 11
	layer.visible = false
	add_child(layer)
	var result := TextureRect.new()
	result.name = "%sLabel" % layer_name
	result.texture = _menu_row_texture(menu_row)
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	result.anchor_left = 0.25
	result.anchor_top = 0.45
	result.anchor_right = 0.75
	result.anchor_bottom = 0.55
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(result)
	return layer


func _set_game_over_visible(value: bool) -> void:
	if game_over_layer != null:
		game_over_layer.visible = value


func _set_arcade_clear_visible(value: bool) -> void:
	if arcade_clear_layer != null:
		arcade_clear_layer.visible = value
	if value:
		player.visible = true
		gum_controller.visible = true
		aim_reticle.visible = false
		_set_player_shadow_visible(true)


func _update_title() -> void:
	_update_title_void_noise(get_process_delta_time())
	if title_accept_blocked_by_fullscreen:
		if not Input.is_action_pressed("fire"):
			title_accept_blocked_by_fullscreen = false
		return
	if Input.is_action_just_pressed("move_up"):
		_move_title_selection(-1)
	elif Input.is_action_just_pressed("move_down"):
		_move_title_selection(1)
	if _accept_just_pressed():
		_start_selected_mode()


func _move_title_selection(direction: int) -> void:
	if direction < 0:
		_select_title_mode(TITLE_VOID_MODE_INDEX - 1 if title_void_revealed else title_mode_index - 1)
	elif direction > 0:
		_select_title_mode(TITLE_VOID_MODE_INDEX if title_mode_index >= TITLE_REGULAR_MODE_COUNT - 1 else title_mode_index + 1)


func _select_title_mode(index: int) -> void:
	title_mode_index = clampi(index, 0, TITLE_MODES.size() - 1)
	title_void_revealed = title_mode_index == TITLE_VOID_MODE_INDEX
	title_void_noise_timer = 0.0
	_refresh_title_menu()


func _refresh_title_menu() -> void:
	var shade_colors := [
		Color(0.96, 0.86, 0.88, 0.78),
		Color(0.86, 0.86, 0.86, 0.72),
		Color(0.025, 0.025, 0.045, 0.54),
		Color(0.075, 0.004, 0.025, 0.58),
		Color(0.018, 0.002, 0.008, 0.72),
	]
	var band_colors := [
		Color(1.0, 0.98, 0.99, 0.50),
		Color(0.94, 0.94, 0.94, 0.42),
		Color(0.10, 0.10, 0.14, 0.48),
		Color(0.12, 0.01, 0.05, 0.52),
		Color(0.035, 0.002, 0.012, 0.68),
	]
	if is_instance_valid(title_shade):
		title_shade.color = shade_colors[title_mode_index]
		title_band.color = band_colors[title_mode_index]
	for index in range(title_menu_buttons.size()):
		var button := title_menu_buttons[index]
		button.visible = title_void_revealed == (index == TITLE_VOID_MODE_INDEX)
		var selected_alpha := 0.34 if index == TITLE_VOID_MODE_INDEX else 1.0
		button.modulate = Color(1.0, 1.0, 1.0, selected_alpha if index == title_mode_index else 0.18)


func _update_title_void_noise(delta: float) -> void:
	if not title_void_revealed or title_menu_buttons.size() <= TITLE_VOID_MODE_INDEX:
		return
	title_void_noise_timer -= delta
	if title_void_noise_timer > 0.0:
		return
	title_void_noise_timer = randf_range(0.045, 0.18)
	var flash := randf() < 0.10
	var alpha := randf_range(0.16, 0.36) if not flash else randf_range(0.46, 0.68)
	var tint := randf_range(0.70, 0.94)
	title_menu_buttons[TITLE_VOID_MODE_INDEX].modulate = Color(tint, 0.94 + (1.0 - tint) * 0.3, 1.0, alpha)


func _menu_row_texture(index: int, crop_side_bars := false) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = MENU_ATLAS
	var crop := TITLE_VOID_SIDE_CROP if crop_side_bars else 0
	texture.region = Rect2(
		float(crop) * UI_SVG_SCALE,
		float(index * MENU_ROW_HEIGHT) * UI_SVG_SCALE,
		float(340 - crop * 2) * UI_SVG_SCALE,
		float(MENU_ROW_HEIGHT) * UI_SVG_SCALE
	)
	texture.filter_clip = true
	return texture


func _start_selected_mode() -> void:
	_start_title_mode(title_mode_index)


func _start_title_mode(index: int) -> void:
	_select_title_mode(index)
	if title_mode_index == 0:
		_start_arcade()
	else:
		_start_endless(title_mode_index)


func _update_arcade_clear() -> void:
	if _accept_just_pressed():
		_return_to_title()


func _update_arcade_clear_scene(delta: float) -> void:
	game_time_scale = move_toward(game_time_scale, 1.0, delta * 2.0)
	_update_bullet_time_glitch(delta)
	player.update_motion(delta, FIELD_W, FIELD_H, FIELD_EDGE_MARGIN)
	_refresh_gamepad_aim_anchor()
	_update_player_spawn_effect(delta)
	_update_player_shadow()
	_update_player_backfire(delta)
	gum_controller.update_controller(delta, player.pos, player.angle, player.aim_pos, bullet_manager.bullets, enemies, bullet_manager.shape_for, _gamepad_gum_launch_bounds())
	bullet_manager.update_bullets(delta, FIELD_W, FIELD_H, DESPAWN_MARGIN, false, _player_hit_axis(), enemies)
	bullet_manager.flush_visual_batches()
	_update_debug_profile(delta)
	_update_hud()


func _update_game_over() -> void:
	if _accept_just_pressed():
		_return_to_title()


func _update_game_over_scene(delta: float) -> void:
	game_time_scale = move_toward(game_time_scale, 1.0, delta * 2.0)
	_update_bullet_time_glitch(delta)
	bullet_manager.update_bullets(delta, FIELD_W, FIELD_H, DESPAWN_MARGIN, false, _player_hit_axis(), enemies)
	_update_enemies(delta)
	_update_boss_gum_attack(delta, false)
	_update_spawning(delta, false)
	_update_enemy_visual_batches()
	bullet_manager.flush_visual_batches()
	_update_debug_profile(delta)
	_update_hud()


func _start_arcade() -> void:
	game_state.start_arcade()
	_set_title_visible(false)
	_set_game_over_visible(false)
	_set_arcade_clear_visible(false)
	_reset_runtime_state()


func _start_endless(difficulty: int) -> void:
	game_state.start_endless(difficulty)
	_set_title_visible(false)
	_set_game_over_visible(false)
	_set_arcade_clear_visible(false)
	_reset_runtime_state()


func _handle_escape() -> void:
	if gallery_active:
		_set_gallery_active(false)
		return
	if not game_state.game_started:
		get_tree().quit()
		return
	_return_to_title()


func _return_to_title() -> void:
	_set_gallery_active(false)
	_select_title_mode(0)
	game_state.game_started = false
	game_state.arcade_cleared = false
	game_state.game_over = false
	game_state.boss_mode = false
	boss.reset()
	spawner.reset()
	player.reset()
	sfx.stop_all()
	bgm.stop()
	backfire_timer = 0.0
	player_spawn_effect_timer = 0.0
	_reset_gum()
	boss_gum_controller.reset()
	_clear_enemies()
	_clear_bullets()
	_set_game_over_visible(false)
	_set_arcade_clear_visible(false)
	_set_title_visible(true)
	_update_player_shadow()
	_update_aim_reticle(0.0)


func _setup_debug() -> void:
	debug_root = DebugOverlayUtil.new()
	debug_root.name = "DebugCollisions"
	add_child(debug_root)


func _kill_player() -> void:
	if not player.can_be_hit():
		return
	game_state.reset_tension()
	game_state.player_lives -= 1
	if not player.kill(game_state.player_lives):
		return
	sfx.play("die")
	_spawn_player_burst(player.pos)
	_reset_gum()
	var core := _boss_core_enemy()
	if not core.is_empty():
		boss_gum_controller.restart_cycle(core.pos)
	if game_state.player_lives >= 0:
		call_deferred("_clear_bullets")


func _show_game_over() -> void:
	game_state.enter_game_over()
	bgm.stop()
	_set_game_over_visible(true)
	_update_hud()


func _reset_runtime_state() -> void:
	sfx.stop_all()
	if game_state.game_mode == "endless":
		game_state.reset_for_endless()
	else:
		game_state.reset_for_arcade()
	boss.reset()
	spawner.reset()
	player.reset()
	backfire_timer = 0.0
	player_spawn_effect_timer = SPAWN_EFFECT_TIME
	_reset_gum()
	boss_gum_controller.reset()
	_clear_enemies()
	_clear_bullets()


func _reset_gum() -> void:
	gum_controller.reset(player.pos)


func _player_can_be_hit() -> bool:
	return player.can_be_hit()


func _update_enemies(delta: float) -> void:
	var live: Array[Dictionary] = []
	var boss_defeated := false
	for enemy in enemies:
		enemy.age += delta
		if EnemyUtil.is_boss(enemy):
			if boss.update_enemy(enemy, delta, player.pos, bullet_manager, game_state, enemies):
				boss_defeated = true
			if enemy.get("core_just_unlocked", false):
				_spawn_boss_core_unlock_effect(enemy.pos)
		elif enemy.kind == "zako0":
			var to_player: Vector2 = player.pos - enemy.pos
			var desired: float = to_player.angle()
			var previous_angle: float = enemy.angle
			enemy.angle = lerp_angle(enemy.angle, desired, delta * 2.3)
			enemy.pos += Vector2(cos(enemy.angle), sin(enemy.angle)) * delta * EnemyUtil.ZAKO0_SPEED
			enemy.node.rotation.y = -enemy.angle - PI * 0.5
			var turn_input := _normalized_turn_input(
				previous_angle,
				enemy.angle,
				delta,
				ZAKO0_VISUAL_FULL_BANK_TURN_RATE
			)
			_update_moving_visual(
				enemy.node as Node3D,
				enemy.get("visual_model") as Node3D,
				Vector2.from_angle(enemy.angle),
				turn_input,
				delta,
				ZAKO0_VISUAL_MAX_BANK,
				ZAKO0_VISUAL_MAX_PITCH,
				ZAKO0_VISUAL_RESPONSE
			)
		elif enemy.kind == "zako1":
			var desired: float = (player.pos - enemy.pos).angle()
			enemy.angle = lerp_angle(enemy.angle, desired, delta * 1.0)
			enemy.pos += Vector2.from_angle(enemy.angle) * delta * EnemyUtil.ZAKO1_SPEED
			enemy.node.rotation.y = -enemy.angle - PI * 0.5
			var visual_model := enemy.get("visual_model") as Node3D
			if visual_model != null:
				_update_zako1_visual_roll(visual_model, delta)
		elif enemy.kind == "zako2":
			var previous_pos: Vector2 = enemy.pos
			var to_player: Vector2 = player.pos - enemy.pos
			var desired: float = to_player.angle()
			enemy.pos += Vector2.from_angle(enemy.drift_angle) * delta * EnemyUtil.ZAKO2_SPEED
			enemy.pos += Vector2.from_angle(desired) * delta * EnemyUtil.ZAKO2_HOMING_SPEED
			var turn: float = (4.0 + 1.8 * sin(enemy.age * 6.0)) * enemy.rev
			enemy.drift_angle += delta * turn
			enemy.angle += delta * 6.0 * enemy.rev
			var motion_angle: float = (enemy.pos - previous_pos).angle()
			_update_enemy_motion_visual(
				enemy, motion_angle, delta,
				ZAKO2_VISUAL_MAX_BANK, ZAKO2_VISUAL_MAX_PITCH,
				ZAKO2_VISUAL_RESPONSE, ZAKO2_VISUAL_FULL_BANK_TURN_RATE,
				enemy.spin
			)
			if enemy.age > 0.8 and fmod(enemy.age + enemy.fire_offset, 1.05) < delta:
				bullet_manager.spawn_hostile_bullet(enemy.pos, desired, BulletManagerUtil.BULLET0_SPEED, true, "circle")
		elif enemy.kind == "zako4":
			var previous_pos: Vector2 = enemy.pos
			var turn: float = (2.0 + 2.0 * sin(enemy.age * 3.0)) * enemy.rev
			enemy.drift_angle += delta * turn
			enemy.angle += delta * 7.5 * enemy.rev
			enemy.pos += Vector2.from_angle(enemy.drift_angle) * delta * EnemyUtil.ZAKO4_SPEED
			var motion_angle: float = (enemy.pos - previous_pos).angle()
			_update_enemy_motion_visual(
				enemy, motion_angle, delta,
				ZAKO4_VISUAL_MAX_BANK, ZAKO4_VISUAL_MAX_PITCH,
				ZAKO4_VISUAL_RESPONSE, ZAKO4_VISUAL_FULL_BANK_TURN_RATE,
				ZAKO4_VISUAL_SPIN_SPEED * enemy.rev
			)
			if enemy.age > 0.9 and fmod(enemy.age + enemy.fire_offset, 1.15) < delta:
				for i in range(4):
					var muzzle := _zako4_muzzle_pose(enemy, i)
					bullet_manager.spawn_hostile_bullet(muzzle.pos, muzzle.angle, BulletManagerUtil.BULLET2_SPEED, true, "capsule")
		elif enemy.kind == "zako3":
			enemy.node.rotate_object_local(enemy.tumble_axis, delta * enemy.tumble_speed)
			if enemy.age > 15.0:
				enemy.life = 0
		elif enemy.kind == "zako3p":
			var desired: float = (player.pos - enemy.pos).angle()
			enemy.angle = lerp_angle(enemy.angle, desired, delta * 3.0)
			enemy.pos += Vector2.from_angle(enemy.angle) * delta * EnemyUtil.ZAKO3P_SPEED
			_update_enemy_motion_visual(
				enemy, enemy.angle, delta,
				ZAKO3P_VISUAL_MAX_BANK, ZAKO3P_VISUAL_MAX_PITCH,
				ZAKO3P_VISUAL_RESPONSE, ZAKO3P_VISUAL_FULL_BANK_TURN_RATE,
				0.0, ZAKO3P_VISUAL_ROLL_SPEED * enemy.rev
			)
		elif enemy.kind == "zako5":
			var movement_angle: float = enemy.angle
			enemy.pos += Vector2.from_angle(movement_angle) * delta * EnemyUtil.ZAKO5_SPEED
			_bounce_enemy_angle(enemy)
			var desired: float = (player.pos - enemy.pos).angle()
			enemy.angle = _turn_toward_angle(enemy.angle, desired, ZAKO5_TURN_RATE * delta)
			_update_enemy_motion_visual(
				enemy, enemy.angle, delta,
				ZAKO5_VISUAL_MAX_BANK, ZAKO5_VISUAL_MAX_PITCH,
				ZAKO5_VISUAL_RESPONSE, ZAKO5_VISUAL_FULL_BANK_TURN_RATE
			)
			if enemy.age > 0.6 and fmod(enemy.age + enemy.fire_offset, ZAKO5_LINE_BULLET_INTERVAL) < delta:
				bullet_manager.spawn_hostile_bullet(enemy.pos, movement_angle, 0.0, true, "line", 2.0, ZAKO5_LINE_BULLET_LENGTH)
		elif enemy.kind == "zako6":
			enemy.drift_angle += delta * enemy.rev
			enemy.angle += delta * 8.0 * enemy.rev
			enemy.pos += Vector2.from_angle(enemy.drift_angle) * delta * EnemyUtil.ZAKO6_SPEED
			_bounce_enemy_drift(enemy)
			_update_enemy_motion_visual(
				enemy, enemy.drift_angle, delta,
				ZAKO6_VISUAL_MAX_BANK, ZAKO6_VISUAL_MAX_PITCH,
				ZAKO6_VISUAL_RESPONSE, ZAKO6_VISUAL_FULL_BANK_TURN_RATE,
				ZAKO6_VISUAL_SPIN_SPEED * enemy.rev
			)
		elif enemy.kind == "zako7":
			enemy.angle += delta * enemy.rev * 1.4
			enemy.pos += Vector2.from_angle(enemy.angle) * delta * EnemyUtil.ZAKO7_SPEED
			_bounce_enemy_angle(enemy)
			_update_enemy_motion_visual(
				enemy, enemy.angle, delta,
				ZAKO7_VISUAL_MAX_BANK, ZAKO7_VISUAL_MAX_PITCH,
				ZAKO7_VISUAL_RESPONSE, ZAKO7_VISUAL_FULL_BANK_TURN_RATE
			)
		elif enemy.kind == "zako7p":
			if enemy.chain_released:
				var desired: float = (player.pos - enemy.pos).angle()
				enemy.angle = lerp_angle(enemy.angle, desired, delta * 4.0)
				enemy.pos += Vector2.from_angle(enemy.angle) * delta * EnemyUtil.ZAKO7P_SPEED
			else:
				_update_chain_segment(enemy, delta)
			var max_bank := ZAKO7P_RELEASED_VISUAL_MAX_BANK if enemy.chain_released else ZAKO7P_CHAIN_VISUAL_MAX_BANK
			var max_pitch := ZAKO7P_RELEASED_VISUAL_MAX_PITCH if enemy.chain_released else ZAKO7P_CHAIN_VISUAL_MAX_PITCH
			var roll_speed := ZAKO7P_RELEASED_VISUAL_ROLL_SPEED if enemy.chain_released else ZAKO7P_CHAIN_VISUAL_ROLL_SPEED
			_update_enemy_motion_visual(
				enemy, enemy.angle, delta,
				max_bank, max_pitch,
				ZAKO7P_VISUAL_RESPONSE, ZAKO7P_VISUAL_FULL_BANK_TURN_RATE,
				0.0, roll_speed * enemy.rev
			)
		elif enemy.kind == "zakoM0":
			enemy.angle = lerp_angle(enemy.angle, (player.pos - enemy.pos).angle(), delta * 1.2)
			enemy.node.rotation.y = -enemy.angle + PI * 0.5
			_update_zako_m0_body_tilt(enemy)
			_update_zako_m0_guns(enemy, delta)
		elif enemy.kind == "zakoM1":
			var desired: float = (player.pos - enemy.pos).angle()
			enemy.angle = lerp_angle(enemy.angle, desired, delta * 2.0)
			enemy.pos += Vector2.from_angle(enemy.angle) * delta * EnemyUtil.ZAKOM1_SPEED
			enemy.node.rotation.y = -enemy.angle - PI * 0.5
			var visual_model := enemy.get("visual_model") as Node3D
			if visual_model != null:
				_update_zako_m1_visual_roll(visual_model, delta)

		_update_spawn_collision_state(enemy)
		enemy.node.position = _to_world(enemy.pos, _enemy_visual_height(enemy.kind))
		_apply_spawn_effect(enemy.node, enemy.age, 2.0, 0.35)
		if not EnemyUtil.is_boss(enemy) and enemy.kind not in ["zakoM0", "zakoM1", "zako0", "zako1", "zako2", "zako3", "zako3p", "zako4", "zako5", "zako6", "zako7", "zako7p"]:
			enemy.node.rotation.y += delta * enemy.spin
		if (
			not enemy.get("spawn_collision_locked", false)
			and enemy.kind != "boss_core"
			and _player_can_be_hit()
			and _is_player_hit_by_enemy(enemy.pos, enemy.radius)
		):
			if _enemy_is_destroyed_on_player_contact(enemy):
				enemy.life = 0
			_kill_player()
		if enemy.kind == "boss_core" and enemy.life <= 0:
			boss_defeated = true
			_play_boss_core_destroy_sfx()
			_spawn_boss_destroy_effect(enemy.pos, enemy.color, enemy.node as Node3D)
			_free_enemy_nodes(enemy)
		elif _enemy_stays_live(enemy):
			live.append(enemy)
		else:
			var killed: bool = enemy.life <= 0
			if killed:
				_play_enemy_destroy_sfx(enemy)
				if enemy.kind.begins_with("boss_turret"):
					_spawn_enemy_destroy_effect(enemy.pos, palette.boss_core, enemy.radius, enemy.color, 0.20)
				else:
					_spawn_enemy_destroy_effect(enemy.pos, enemy.color, enemy.radius)
			var death_action := EnemyUtil.death_action(enemy)
			if death_action == EnemyUtil.DEATH_SPAWN_ZAKO3_PARTS:
				call_deferred("_spawn_zako3_parts", enemy.pos, enemy.angle)
			if death_action == EnemyUtil.DEATH_RELEASE_ZAKO7_CHAIN:
				call_deferred("_release_zako7_chain", enemy.chain_id)
			if killed:
				var score_base: int = enemy.get("score_base", 0)
				game_state.add_enemy_score(score_base)
			_free_enemy_nodes(enemy)
	enemies = live
	if boss_defeated:
		_end_boss_mode()


func _play_enemy_destroy_sfx(enemy: Dictionary) -> void:
	var kind: String = enemy.kind
	if kind in ["zakoM0", "zakoM1"] or kind.begins_with("boss_turret"):
		sfx.play("bomb_m")
		return
	if kind == "zako3p":
		sfx.play("bomb_s", Vector2i(16, 47))
	elif kind == "zako4":
		sfx.play("bomb_s", Vector2i(48, 79))
	else:
		sfx.play("bomb_s")


func _play_boss_core_destroy_sfx() -> void:
	# Original Boss_Core.onDie plays the extend reward before the explosion.
	_play_extend()
	sfx.play("bomb_m")


func _update_spawning(delta: float, allow_boss := true) -> void:
	if game_state.arcade_cleared:
		return
	var should_start_boss := allow_boss and game_state.should_start_boss(ENABLE_BOSS_MODE)
	var spawn_request := spawner.update(delta, game_state.game_mode, game_state.arcade_rank, game_state.boss_mode, should_start_boss, enemies, FIELD_W, FIELD_H, SPAWN_MARGIN, player.pos)
	if spawn_request.is_empty():
		return
	if spawn_request.get("start_boss", false):
		if allow_boss:
			_start_boss_mode()
		return
	_spawn_enemy(spawn_request.kind, spawn_request.pos)


func _update_hud() -> void:
	var phase := "BOSS" if game_state.boss_mode else "RUSH"
	var debug_text := ""
	if debug_collisions:
		debug_text = "stage %d  next boss %d  bullets %d  enemies %d  pressure %d  time %.0f%%\n%s" % [
			game_state.music_stage,
			game_state.next_arcade_boss_rank(),
			bullet_manager.count(),
			enemies.size(),
			object_pressure,
			game_time_scale * 100.0,
			_debug_profile_summary(),
		]
	hud.update_values(
		int(game_state.score),
		int(game_state.hi_score),
		maxi(0, game_state.player_lives),
		gum_controller.energy,
		game_state.tension,
		phase,
		game_state.arcade_rank,
		player.life_state_text(),
		gum_controller.state_name(),
		debug_text
	)


func _hud_text() -> String:
	var gum_name: String = gum_controller.state_name()
	var phase := "BOSS" if game_state.boss_mode else "RUSH"
	var life_state: String = player.life_state_text()
	var text := "%s  score %d  hi %d  rank %d  lives %d  %s\nGum %s %.0f%%  tension %.0f" % [
		phase,
		int(game_state.score),
		int(game_state.hi_score),
		game_state.arcade_rank,
		max(0, game_state.player_lives),
		life_state,
		gum_name,
		gum_controller.energy * 100.0,
		game_state.tension,
	]
	if debug_collisions:
		text += "\nstage %d  next boss %d  bullets %d  enemies %d  pressure %d  time %.0f%%\n%s" % [
			game_state.music_stage,
			game_state.next_arcade_boss_rank(),
			bullet_manager.count(),
			enemies.size(),
			object_pressure,
			game_time_scale * 100.0,
			_debug_profile_summary(),
		]
	return text


func _debug_profile_summary() -> String:
	return debug_profile_text if not debug_profile_text.is_empty() else "visual meshes -  top -"


func _update_game_timing(delta: float) -> void:
	object_pressure = TimingUtil.compute_object_pressure(bullet_manager.count(), enemies.size(), game_state.boss_mode)
	var target_time_scale := TimingUtil.compute_time_scale(object_pressure)
	game_time_scale = TimingUtil.approach_time_scale(game_time_scale, target_time_scale, delta)


func _update_debug_profile(delta: float) -> void:
	if not debug_collisions:
		debug_profile_timer = 0.0
		debug_profile_log_timer = 0.0
		debug_profile_text = ""
		return
	debug_profile_timer -= delta
	debug_profile_log_timer -= delta
	if debug_profile_timer > 0.0:
		return
	debug_profile_timer = 0.50

	var kind_counts := {}
	var kind_meshes := {}
	var total_meshes := 0
	for enemy in enemies:
		var kind: String = enemy.kind
		kind_counts[kind] = int(kind_counts.get(kind, 0)) + 1
		var mesh_count := _count_mesh_instances(enemy.get("node") as Node)
		kind_meshes[kind] = int(kind_meshes.get(kind, 0)) + mesh_count
		total_meshes += mesh_count
	for kind in BATCHED_ENEMY_KINDS:
		if int(kind_counts.get(kind, 0)) <= 0 or not enemy_visual_batches.has(kind):
			continue
		var batch := enemy_visual_batches[kind] as Dictionary
		var batch_mesh_count := (batch.visual_entries as Array).size()
		kind_meshes[kind] = int(kind_meshes.get(kind, 0)) + batch_mesh_count
		total_meshes += batch_mesh_count

	var ranked := []
	for kind in kind_counts:
		ranked.append({
			"kind": kind,
			"count": int(kind_counts[kind]),
			"meshes": int(kind_meshes.get(kind, 0)),
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.meshes) == int(b.meshes):
			return int(a.count) > int(b.count)
		return int(a.meshes) > int(b.meshes)
	)
	var entries := []
	for i in range(mini(4, ranked.size())):
		var entry := ranked[i] as Dictionary
		entries.append("%s %d/%d" % [entry.kind, entry.count, entry.meshes])
	debug_profile_text = "visual meshes %d  top %s" % [total_meshes, "  ".join(entries)]
	if debug_profile_log_timer <= 0.0:
		debug_profile_log_timer = 2.0
		print("Debug profile: enemies=%d bullets=%d pressure=%d time=%.0f%% meshes=%d top=%s" % [
			enemies.size(),
			bullet_manager.count(),
			object_pressure,
			game_time_scale * 100.0,
			total_meshes,
			", ".join(entries),
		])


func _count_mesh_instances(node: Node) -> int:
	if node == null:
		return 0
	var count := 1 if node is MeshInstance3D or node is MultiMeshInstance3D else 0
	for child in node.get_children():
		count += _count_mesh_instances(child)
	return count


func _update_bullet_time_glitch(delta: float) -> void:
	if bullet_time_glitch == null:
		return
	var active := game_state.game_started and not game_state.arcade_cleared and player.alive
	var intensity := 0.0
	if active:
		intensity = TimingUtil.bullet_time_intensity(game_time_scale)
	var screen_pos := camera.unproject_position(_to_world(player.pos, 0.32)) if active else Vector2.ZERO
	bullet_time_glitch.update_effect(delta, screen_pos, intensity)
	time_warp_audio.update_effect(bullet_time_glitch.intensity)


func _update_debug_collisions() -> void:
	debug_root.set_enabled(debug_collisions)
	if not debug_collisions:
		return

	debug_root.begin_shapes()
	if player.alive:
		var axis := _player_hit_axis()
		debug_root.show_capsule(axis[0], axis[1], PlayerUtil.HIT_RADIUS, Color(1.0, 1.0, 0.15, 0.95))
	for enemy in enemies:
		var enemy_color := Color(1.0, 0.25, 0.25, 0.85)
		if enemy.kind == "boss_core":
			enemy_color = Color(0.25, 0.90, 1.0, 0.95) if enemy.get("damageable", true) else Color(0.45, 0.58, 0.66, 0.80)
		elif enemy.kind.begins_with("boss_turret"):
			enemy_color = Color(1.0, 0.70, 0.18, 0.95) if enemy.get("damageable", true) else Color(0.65, 0.48, 0.28, 0.80)
		debug_root.show_circle(enemy.pos, enemy.radius, enemy_color)
	bullet_manager.show_debug_shapes(debug_root, Color(1.0, 0.15, 0.15, 0.80), Color(0.70, 0.95, 1.0, 0.80))
	for orb_pos in gum_controller.debug_orb_positions():
		debug_root.show_circle(orb_pos, GumControllerUtil.BULLET_RADIUS, Color(1.0, 0.35, 0.9, 0.85))
		debug_root.show_circle(orb_pos, GumControllerUtil.ENEMY_RADIUS, Color(0.9, 0.55, 1.0, 0.65))
	for orb_pos in boss_gum_controller.active_positions():
		debug_root.show_circle(orb_pos, BossGumControllerUtil.COLLISION_RADIUS, Color(0.25, 0.76, 1.0, 0.90))
	debug_root.end_shapes()


func _spawn_enemy(kind: String, pos: Vector2) -> void:
	if game_state.arcade_cleared:
		return
	var color: Color = palette[kind]
	var node := Node3D.new()
	node.name = "%s-%s" % [kind, EnemyUtil.display_name(kind).to_snake_case()]
	var gun0: Node3D = null
	var gun1: Node3D = null
	var visual_model: Node3D = null
	if kind == "zako0":
		visual_model = _attach_batched_enemy_visual(node, kind)
	elif kind == "zako1":
		visual_model = _attach_batched_enemy_visual(node, kind, Vector3.ONE * ZAKO1_VISUAL_SCALE)
	elif kind == "zako2":
		visual_model = _attach_batched_enemy_visual(node, kind)
	elif kind == "zako3":
		_ensure_enemy_visual_batch(kind)
	elif kind == "zako3p":
		visual_model = _attach_batched_zako3p_visual(node)
	elif kind == "zako4":
		var zako4_model := _zako4_diamond_battery_marker_model()
		visual_model = _attach_motion_visual(node, zako4_model)
		node.set_meta("spin_model", zako4_model)
	elif kind == "zako5":
		visual_model = _attach_batched_enemy_visual(node, kind, Vector3.ONE * ZAKO5_VISUAL_SCALE)
	elif kind == "zako6":
		visual_model = _attach_batched_enemy_visual(node, kind)
	elif kind == "zako7":
		visual_model = _attach_batched_enemy_visual(node, kind, Vector3.ONE * ZAKO7_VISUAL_SCALE)
	elif kind == "zako7p":
		visual_model = _attach_batched_enemy_visual(node, kind)
	elif kind == "zakoM0":
		visual_model = _attach_batched_enemy_visual(node, kind)
		gun0 = _zako_m0_square_gun(color.lightened(0.10))
		gun1 = _zako_m0_prism_sniper(palette.boss_turret)
		node.add_child(gun0)
		node.add_child(gun1)
	elif kind == "zakoM1":
		visual_model = _attach_batched_enemy_visual(node, kind)
	else:
		node.add_child(_diamond_mesh(0.72, 0.36, color))
		var feeler_a := _line_mesh(Vector2(-0.42, 0.0), Vector2(0.42, 0.0), 0.04, color.lightened(0.25))
		feeler_a.position.y = 0.14
		node.add_child(feeler_a)
		var feeler_b := _line_mesh(Vector2(0.0, -0.42), Vector2(0.0, 0.42), 0.04, color.lightened(0.25))
		feeler_b.position.y = 0.14
		node.add_child(feeler_b)
	if _enemy_uses_visual_batch(kind):
		_ensure_enemy_visual_batch(kind)
	node.position = _to_world(pos, _enemy_visual_height(kind))
	add_child(node)
	var angle := randf() * TAU
	var chain_id := -1
	if kind == "zako7":
		chain_seq += 1
		chain_id = chain_seq
	var enemy := EnemyUtil.create_zako(kind, node, pos, angle, color, chain_id, gun0, gun1)
	enemy.visual_model = visual_model
	enemy.spin_model = node.get_meta("spin_model") if node.has_meta("spin_model") else null
	if _enemy_uses_visual_batch(kind):
		enemy.visual_batch_kind = kind
	enemy.visual_heading = enemy.drift_angle if kind in ["zako2", "zako4", "zako6"] else enemy.angle
	_lock_spawn_collision(enemy)
	enemies.append(enemy)
	if kind == "zako7":
		_spawn_zako7_chain(pos, angle, chain_id)


func _lock_spawn_collision(enemy: Dictionary) -> void:
	enemy.spawn_collision_locked = true
	enemy.spawn_damageable = enemy.get("damageable", true)
	enemy.spawn_gum_vulnerable = enemy.get("gum_vulnerable", true)
	enemy.spawn_blocks_shots = enemy.get("blocks_shots", false)
	enemy.damageable = false
	enemy.gum_vulnerable = false
	enemy.blocks_shots = false


func _update_zako1_visual_roll(visual_model: Node3D, delta: float) -> void:
	visual_model.rotate_object_local(Vector3.FORWARD, delta * ZAKO1_VISUAL_ROLL_SPEED)


func _update_zako_m1_visual_roll(visual_model: Node3D, delta: float) -> void:
	visual_model.rotate_object_local(Vector3.FORWARD, delta * ZAKOM1_VISUAL_ROLL_SPEED)


func _update_zako_m0_body_tilt(enemy: Dictionary) -> void:
	var visual_model := enemy.get("visual_model") as Node3D
	var root_node := enemy.get("node") as Node3D
	if visual_model == null or root_node == null:
		return
	var outward: Vector2 = enemy.pos.normalized()
	if outward.is_zero_approx():
		outward = Vector2.from_angle(float(enemy.angle))
	var outward_3d := Vector3(outward.x, 0.0, outward.y)
	var tilt_axis := Vector3.UP.cross(outward_3d).normalized()
	var outward_yaw := -outward.angle() - PI * 0.5
	var desired_global_basis := Basis(Quaternion(tilt_axis, ZAKOM0_OUTWARD_TILT)) * Basis(Vector3.UP, outward_yaw)
	visual_model.basis = root_node.basis.orthonormalized().inverse() * desired_global_basis


func _update_moving_visual(
	root_node: Node3D,
	visual_model: Node3D,
	world_motion: Vector2,
	turn_input: float,
	delta: float,
	max_bank: float,
	max_pitch: float,
	response: float
) -> void:
	if root_node == null or visual_model == null:
		return
	var local_direction := VisualMotionUtil.local_motion(root_node, world_motion)
	VisualMotionUtil.update_bank_pitch(visual_model, local_direction, turn_input, delta, max_bank, max_pitch, response)


func _attach_motion_visual(root_node: Node3D, model: Node3D) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = "%s-motion" % model.name
	root_node.add_child(pivot)
	pivot.add_child(model)
	return pivot


func _attach_batched_zako3p_visual(root_node: Node3D) -> Node3D:
	_ensure_enemy_visual_batch("zako3p")
	var model := Node3D.new()
	model.name = "zako3p-low-wedge"
	model.scale = Vector3.ONE * ZAKO3P_VISUAL_SCALE
	var pivot := _attach_motion_visual(root_node, model)
	root_node.set_meta("spin_model", model)
	return pivot


func _attach_batched_enemy_visual(root_node: Node3D, kind: String, model_scale := Vector3.ONE) -> Node3D:
	_ensure_enemy_visual_batch(kind)
	var model := Node3D.new()
	model.name = "%s-batched-visual" % kind
	model.scale = model_scale
	var pivot := _attach_motion_visual(root_node, model)
	root_node.set_meta("spin_model", model)
	return pivot


func _update_enemy_motion_visual(
	enemy: Dictionary,
	heading: float,
	delta: float,
	max_bank: float,
	max_pitch: float,
	response: float,
	full_bank_turn_rate: float,
	yaw_spin_speed := 0.0,
	roll_speed := 0.0
) -> void:
	var root_node := enemy.get("node") as Node3D
	var visual_pivot := enemy.get("visual_model") as Node3D
	if root_node == null or visual_pivot == null:
		return
	var previous_heading := float(enemy.get("visual_heading", heading))
	enemy.visual_heading = heading
	root_node.rotation.y = -heading - PI * 0.5
	var turn_input := _normalized_turn_input(previous_heading, heading, delta, full_bank_turn_rate)
	_update_moving_visual(
		root_node, visual_pivot, Vector2.from_angle(heading), turn_input, delta,
		max_bank, max_pitch, response
	)
	var spin_model := enemy.get("spin_model") as Node3D
	if spin_model != null:
		if not is_zero_approx(yaw_spin_speed):
			# Root yaw follows the trajectory; compensate it so the model keeps its intended world-space spin.
			spin_model.rotate_y(yaw_spin_speed * delta + angle_difference(previous_heading, heading))
		if not is_zero_approx(roll_speed):
			spin_model.rotate_object_local(Vector3.FORWARD, roll_speed * delta)


func _normalized_turn_input(previous_angle: float, current_angle: float, delta: float, full_bank_turn_rate: float) -> float:
	var angular_velocity := angle_difference(previous_angle, current_angle) / maxf(0.001, delta)
	return clampf(angular_velocity / maxf(0.001, full_bank_turn_rate), -1.0, 1.0)


func _turn_toward_angle(current: float, target: float, max_delta: float) -> float:
	return current + clampf(angle_difference(current, target), -max_delta, max_delta)


func _enemy_visual_height(kind: String) -> float:
	if kind in ["zako0", "zako1", "zako2", "zako3p", "zako4", "zako5", "zako6", "zako7", "zako7p"]:
		return MOVING_CHARACTER_VISUAL_HEIGHT
	return DEFAULT_ENEMY_VISUAL_HEIGHT


func _zako4_muzzle_pose(enemy: Dictionary, index: int) -> Dictionary:
	var root_node := enemy.get("node") as Node3D
	var spin_model := enemy.get("spin_model") as Node3D
	if root_node == null or spin_model == null:
		return {"pos": enemy.pos, "angle": enemy.angle + TAU * float(index) / 4.0}
	root_node.position = _to_world(enemy.pos, _enemy_visual_height(enemy.kind))
	var marker := spin_model.find_child("zako4-muzzle-%d" % index, true, false) as Node3D
	if marker == null:
		return {"pos": enemy.pos, "angle": enemy.angle + TAU * float(index) / 4.0}
	var marker_pos := marker.global_position
	var forward_3d := marker.global_basis * Vector3.FORWARD
	var forward := Vector2(forward_3d.x, forward_3d.z).normalized()
	return {
		"pos": Vector2(marker_pos.x, marker_pos.z),
		"angle": forward.angle(),
	}


func _update_spawn_collision_state(enemy: Dictionary) -> void:
	if enemy.get("spawn_collision_locked", false):
		if enemy.age < ENEMY_SPAWN_INVULN_TIME:
			return
		_activate_spawn_collision(enemy)


func _activate_spawn_collision(enemy: Dictionary) -> void:
	enemy.spawn_collision_locked = false
	enemy.damageable = enemy.get("spawn_damageable", true)
	enemy.gum_vulnerable = enemy.get("spawn_gum_vulnerable", true)
	enemy.blocks_shots = enemy.get("spawn_blocks_shots", false)


func _spawn_zako3_parts(pos: Vector2, angle: float) -> void:
	for i in range(4):
		var part_angle := angle + PI * 0.5 + randf_range(0.0, PI)
		_spawn_enemy("zako3p", pos + Vector2.from_angle(part_angle) * 0.15)
		var part: Dictionary = enemies.back()
		part.angle = part_angle
		part.drift_angle = part_angle
		part.visual_heading = part_angle
		_activate_spawn_collision(part)


func _spawn_zako7_chain(pos: Vector2, angle: float, chain_id: int) -> void:
	var segment_count := 8
	for i in range(1, segment_count + 1):
		var segment_pos := pos - Vector2.from_angle(angle) * ZAKO7_CHAIN_SPACING * float(i)
		_spawn_enemy("zako7p", segment_pos)
		var part: Dictionary = enemies.back()
		part.angle = angle
		part.drift_angle = angle
		part.visual_heading = angle
		part.chain_id = chain_id
		part.segment = i
		part.spin *= 0.25


func _release_zako7_chain(chain_id: int) -> void:
	for enemy in enemies:
		if enemy.kind != "zako7p" or enemy.chain_id != chain_id or enemy.chain_released:
			continue
		EnemyUtil.release_chain_part(enemy)
		enemy.angle += PI * 0.5 + randf_range(-0.8, 0.8)
		enemy.drift_angle = enemy.angle
		enemy.color = palette.zako3p
		_replace_released_zako7p_visual(enemy)
		_spawn_enemy_destroy_effect(enemy.pos, palette.zako7p, enemy.radius)


func _replace_released_zako7p_visual(enemy: Dictionary) -> void:
	var node := enemy.node as Node3D
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	var motion_pivot := _attach_batched_zako3p_visual(node)
	enemy.visual_model = motion_pivot
	enemy.spin_model = node.get_meta("spin_model")
	enemy.visual_batch_kind = "zako3p"
	enemy.visual_heading = enemy.angle
	node.rotation.y = -enemy.angle - PI * 0.5
	var old_shadow := enemy.get("shadow") as Node3D
	if old_shadow != null and is_instance_valid(old_shadow):
		old_shadow.queue_free()
	enemy.shadow = null


func _update_chain_segment(enemy: Dictionary, delta: float) -> void:
	var leader := _find_chain_leader(enemy.chain_id, enemy.segment - 1)
	if leader.is_empty():
		enemy.pos += Vector2.from_angle(enemy.angle) * delta * EnemyUtil.ZAKO7P_SPEED
		return
	var target_angle: float = (leader.pos - enemy.pos).angle()
	var leader_angle_difference := absf(angle_difference(enemy.angle, leader.angle))
	var turn_speed := ZAKO7_CHAIN_SHARP_TURN_SPEED if leader_angle_difference > ZAKO7_CHAIN_SHARP_TURN_THRESHOLD else ZAKO7_CHAIN_TURN_SPEED
	enemy.angle = rotate_toward(enemy.angle, target_angle, turn_speed * delta)
	var leader_distance: float = enemy.pos.distance_to(leader.pos)
	var follow_speed := EnemyUtil.ZAKO7P_SPEED
	if leader_distance < ZAKO7_CHAIN_SPACING - ZAKO7_CHAIN_DISTANCE_TOLERANCE:
		follow_speed *= 0.5
	elif leader_distance > ZAKO7_CHAIN_SPACING + ZAKO7_CHAIN_DISTANCE_TOLERANCE:
		follow_speed *= 2.0
	enemy.pos += Vector2.from_angle(enemy.angle) * follow_speed * delta


func _find_chain_leader(chain_id: int, segment: int) -> Dictionary:
	for enemy in enemies:
		if enemy.chain_id == chain_id and enemy.segment == segment:
			return enemy
	return {}


func _bounce_enemy_angle(enemy: Dictionary) -> bool:
	return _bounce_enemy_motion(enemy, false)


func _bounce_enemy_drift(enemy: Dictionary) -> bool:
	return _bounce_enemy_motion(enemy, true)


func _bounce_enemy_motion(enemy: Dictionary, use_drift_angle: bool) -> bool:
	var margin := 0.0
	var min_x := -FIELD_W * 0.5 + margin
	var max_x := FIELD_W * 0.5 - margin
	var min_y := -FIELD_H * 0.5 + margin
	var max_y := FIELD_H * 0.5 - margin
	var bounced := false
	if enemy.pos.x < min_x or enemy.pos.x > max_x:
		if use_drift_angle:
			enemy.drift_angle = PI - enemy.drift_angle
		else:
			enemy.angle = PI - enemy.angle
		enemy.pos.x = clampf(enemy.pos.x, min_x, max_x)
		bounced = true
	if enemy.pos.y < min_y or enemy.pos.y > max_y:
		if use_drift_angle:
			enemy.drift_angle = -enemy.drift_angle
		else:
			enemy.angle = -enemy.angle
		enemy.pos.y = clampf(enemy.pos.y, min_y, max_y)
		bounced = true
	return bounced


func _clamp_to_field(pos: Vector2, margin: float) -> Vector2:
	return Vector2(
		clampf(pos.x, -FIELD_W * 0.5 + margin, FIELD_W * 0.5 - margin),
		clampf(pos.y, -FIELD_H * 0.5 + margin, FIELD_H * 0.5 - margin)
	)


func _is_in_field_margin(pos: Vector2, margin: float) -> bool:
	return (
		pos.x >= -FIELD_W * 0.5 - margin
		and pos.x <= FIELD_W * 0.5 + margin
		and pos.y >= -FIELD_H * 0.5 - margin
		and pos.y <= FIELD_H * 0.5 + margin
	)


func _enemy_stays_live(enemy: Dictionary) -> bool:
	if enemy.life <= 0:
		return false
	if enemy.kind == "zako7p" and not enemy.get("chain_released", false):
		return true
	return _is_in_field_margin(enemy.pos, DESPAWN_MARGIN)


func _enemy_is_destroyed_on_player_contact(enemy: Dictionary) -> bool:
	return enemy.kind != "zako7p" or enemy.get("chain_released", false)


func _zako_m0_square_gun(color: Color) -> Node3D:
	var gun := Node3D.new()
	gun.name = "zako-gun0-square"
	var visual := Node3D.new()
	visual.name = "zako-gun0-square-visual"
	visual.scale = Vector3.ONE * 0.80
	gun.add_child(visual)
	for part in [
		[Vector3(0.0, 0.0, -0.25), Vector3(0.50, 0.055, 0.065)],
		[Vector3(0.0, 0.0, 0.25), Vector3(0.50, 0.055, 0.065)],
		[Vector3(-0.25, 0.0, 0.0), Vector3(0.065, 0.055, 0.50)],
		[Vector3(0.25, 0.0, 0.0), Vector3(0.065, 0.055, 0.50)],
	]:
		_add_zako_m0_box_part(visual, part[0], part[1], color)
	return gun


func _zako_m0_prism_sniper(color: Color) -> Node3D:
	var gun := Node3D.new()
	gun.name = "zako-gun1-prism-sniper"
	var visual := Node3D.new()
	visual.name = "zako-gun1-prism-sniper-visual"
	gun.add_child(visual)
	var points := PackedVector3Array([
		Vector3(0.0, 0.16, -0.34), Vector3(-0.20, 0.0, 0.20),
		Vector3(0.20, 0.0, 0.20), Vector3(0.0, -0.12, 0.09),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	visual.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.04), 0.32, 0.75)))
	for edge in [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]]:
		visual.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.08)))
	return gun


func _update_zako_m0_guns(enemy: Dictionary, delta: float) -> void:
	var gun0_local_pos := Vector2(cos(enemy.age * 3.0), sin(enemy.age * 3.0)) * 0.72
	var gun1_local_pos := Vector2(cos(enemy.age * 2.0 + PI), sin(enemy.age * 2.0 + PI)) * 0.55
	var gun0_pos: Vector2 = enemy.pos + _zako_m0_world_offset(enemy, gun0_local_pos)
	var gun1_pos: Vector2 = enemy.pos + _zako_m0_world_offset(enemy, gun1_local_pos)
	if enemy.gun0 != null:
		enemy.gun0.position = _to_world(gun0_local_pos, 0.30)
		enemy.gun0.rotation.y = -(player.pos - gun0_pos).angle() + PI * 0.5 - (enemy.node as Node3D).rotation.y
	if enemy.gun1 != null:
		enemy.gun1.position = _to_world(gun1_local_pos, 0.30)
		enemy.gun1.rotation.y = -(player.pos - gun1_pos).angle() - PI * 0.5 - (enemy.node as Node3D).rotation.y
	if enemy.age > 0.9 and fmod(enemy.age, 0.34) < delta:
		bullet_manager.spawn_hostile_bullet(gun0_pos, (player.pos - gun0_pos).angle(), BulletManagerUtil.BULLET0_SPEED, true, "circle")
		enemy.gun0_recoil = 1.0
	for shot_index in range(ZAKO_GUN1_BURST_SHOT_COUNT):
		var first_shot_time := ZAKO_GUN1_BURST_FIRST_SHOT + float(shot_index) * ZAKO_GUN1_BURST_INTERVAL
		if _crossed_periodic_time(enemy.age - delta, enemy.age, first_shot_time, ZAKO_GUN1_BURST_PERIOD):
			var gun1_angle := (player.pos - gun1_pos).angle()
			var gun1_muzzle_pos := gun1_pos + Vector2.from_angle(gun1_angle) * 0.34
			bullet_manager.spawn_hostile_bullet(gun1_muzzle_pos, gun1_angle, BulletManagerUtil.BULLET1_SPEED, true, "capsule")
			enemy.gun1_recoil = 1.0
	_update_zako_m0_gun_recoil(enemy, delta)


func _crossed_periodic_time(previous_time: float, current_time: float, first_time: float, period: float) -> bool:
	const TIME_EPSILON := 0.000001
	if current_time + TIME_EPSILON < first_time:
		return false
	var cycle := maxi(0, floori((current_time - first_time + TIME_EPSILON) / period))
	var event_time := first_time + float(cycle) * period
	return event_time > previous_time + TIME_EPSILON and event_time <= current_time + TIME_EPSILON


func _zako_m0_world_offset(enemy: Dictionary, local_pos: Vector2) -> Vector2:
	var world_offset: Vector3 = (enemy.node as Node3D).basis * Vector3(local_pos.x, 0.0, local_pos.y)
	return Vector2(world_offset.x, world_offset.z)


func _update_zako_m0_gun_recoil(enemy: Dictionary, delta: float) -> void:
	var gun0_visual := (enemy.gun0 as Node3D).find_child("zako-gun0-square-visual", false, false) as Node3D if enemy.gun0 != null else null
	var gun1_visual := (enemy.gun1 as Node3D).find_child("zako-gun1-prism-sniper-visual", false, false) as Node3D if enemy.gun1 != null else null
	if gun0_visual != null:
		gun0_visual.position.z = enemy.gun0_recoil * ZAKO_GUN0_RECOIL_DISTANCE
	if gun1_visual != null:
		gun1_visual.position.z = enemy.gun1_recoil * ZAKO_GUN1_RECOIL_DISTANCE
	enemy.gun0_recoil = maxf(0.0, enemy.gun0_recoil - delta * ZAKO_GUN0_RECOIL_RECOVERY)
	enemy.gun1_recoil = maxf(0.0, enemy.gun1_recoil - delta * ZAKO_GUN1_RECOIL_RECOVERY)


func _start_boss_mode() -> void:
	game_state.start_boss_mode()
	boss.start(player.pos, FIELD_W, FIELD_H)
	_clear_enemies()
	_clear_bullets()
	_spawn_boss_core()
	var boss_gum_count := BossGumControllerUtil.count_for_mode(
		game_state.game_mode,
		game_state.active_arcade_boss_rank,
		game_state.arcade_rank
	)
	boss_gum_controller.begin_boss(boss_gum_count, boss.center)
	var turret_kinds := _boss_turret_sequence()
	for turret_kind in turret_kinds:
		_spawn_boss_turret(turret_kind)


func _set_arcade_rank(value: int) -> void:
	game_state.set_arcade_rank(value)


func _debug_add_score() -> void:
	if not game_state.game_started:
		_start_arcade()
	game_state.debug_add_score(5000.0)


func _debug_next_rank() -> void:
	if not game_state.game_started:
		_start_arcade()
	_set_arcade_rank((game_state.arcade_rank + 1) % 19)


func _debug_cycle_mode() -> void:
	if game_state.game_mode == "arcade":
		_start_endless(1)
	elif game_state.endless_difficulty < 4:
		_start_endless(game_state.endless_difficulty + 1)
	else:
		_start_arcade()


func _debug_force_boss() -> void:
	if not game_state.game_started:
		_start_arcade()
	if game_state.boss_mode:
		return
	_start_boss_mode()


func _end_boss_mode() -> void:
	boss_gum_controller.reset()
	_award_remaining_boss_turret_scores()
	game_state.grant_boss_extend()
	if game_state.game_mode == "arcade" and game_state.active_arcade_boss_rank == GameStateUtil.ARCADE_MAX_RANK:
		game_state.complete_arcade()
		bgm.stop()
		spawner.reset()
		_clear_enemies()
		_clear_hostile_bullets()
		_set_arcade_clear_visible(true)
		return
	game_state.end_boss_mode()
	spawner.set_delay(1.2)
	_clear_enemies()
	_clear_bullets()


func _award_remaining_boss_turret_scores() -> void:
	for enemy in enemies:
		if not String(enemy.get("kind", "")).begins_with("boss_turret") or int(enemy.get("life", 0)) <= 0:
			continue
		enemy.life = 0
		var score_base := int(enemy.get("score_base", 0))
		game_state.add_enemy_score(score_base, false, GameStateUtil.minimum_score_for_base(score_base))
		sfx.play("bomb_m")
		_spawn_enemy_destroy_effect(enemy.pos, palette.boss_core, enemy.radius, enemy.color, 0.20)


func _clear_enemies() -> void:
	for enemy in enemies:
		_free_enemy_nodes(enemy)
	enemies.clear()
	_clear_enemy_visual_batches()


func _clear_bullets() -> void:
	bullet_manager.clear()


func _enemy_uses_visual_batch(kind: String) -> bool:
	return kind in BATCHED_ENEMY_KINDS


func _ensure_enemy_visual_batch(kind: String) -> Dictionary:
	if enemy_visual_batches.has(kind):
		return enemy_visual_batches[kind]
	var template := _enemy_visual_batch_template(kind)
	var visual_parts: Array[Dictionary] = []
	_collect_enemy_visual_batch_parts(template, Transform3D.IDENTITY, visual_parts, true)
	var batch := {
		"visual_entries": _create_enemy_visual_batch_entries(kind, "Visual", visual_parts, null),
		"shadow_entries": [],
	}
	enemy_visual_batches[kind] = batch
	template.free()
	return batch


func _enemy_visual_batch_template(kind: String) -> Node3D:
	if kind == "zako0":
		return _zako0_dihedral_model(palette.zako0)
	if kind == "zako1":
		return _zako1_thin_wedge_model(palette.zako1)
	if kind == "zako2":
		return _zako2_fan_blocks_light_model(palette.zako2)
	if kind == "zako3":
		return _zako3_split_pod_light_model(palette.zako3, palette.zako3p)
	if kind == "zako3p":
		return _zako3p_low_wedge_model(palette.zako3p)
	if kind == "zako4":
		return _zako4_diamond_battery_light_model(palette.zako4)
	if kind == "zako5":
		return _zako5_armored_ray_model(palette.zako5)
	if kind == "zako6":
		return _zako6_tilted_orbits_model(palette.zako6)
	if kind == "zako7":
		return _zako7_deep_v_glider_model(palette.zako7)
	if kind == "zako7p":
		return _zako7p_mini_crystal_light_model(palette.zako7p)
	if kind == "zakoM0":
		return _zako_m0_lattice_keep_model(palette.zakoM0)
	if kind == "zakoM1":
		return _zako_m1_ridged_crystal_model(palette.zakoM1)
	push_error("No enemy visual batch template for %s" % kind)
	return Node3D.new()


func _enemy_shadow_plate_batch_part(kind: String) -> Dictionary:
	return {
		"mesh": _enemy_shadow_plate_mesh(kind),
		"material": null,
		"transform": Transform3D.IDENTITY,
	}


func _collect_enemy_visual_batch_parts(
	node: Node,
	parent_transform: Transform3D,
	parts: Array[Dictionary],
	include_shadowless: bool
) -> void:
	var node_3d := node as Node3D
	var current_transform := parent_transform
	if node_3d != null:
		current_transform = parent_transform * node_3d.transform
		if not include_shadowless and bool(node_3d.get_meta("skip_model_shadow", false)):
			return
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		parts.append({
			"mesh": mesh_instance.mesh,
			"material": mesh_instance.material_override,
			"transform": current_transform,
		})
	for child in node.get_children():
		_collect_enemy_visual_batch_parts(child, current_transform, parts, include_shadowless)


func _create_enemy_visual_batch_entries(
	kind: String,
	role: String,
	parts: Array[Dictionary],
	override_material: Material
) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for part_index in range(parts.size()):
		var part := parts[part_index]
		var instance := MultiMeshInstance3D.new()
		instance.name = "%s%sBatch%02d" % [kind, role, part_index]
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.material_override = override_material if override_material != null else part.material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = part.mesh
		multimesh.instance_count = 0
		instance.multimesh = multimesh
		enemy_visual_batch_root.add_child(instance)
		entries.append({
			"multimesh": multimesh,
			"local_transform": part.transform,
		})
	return entries


func _clear_enemy_visual_batches() -> void:
	for batch in enemy_visual_batches.values():
		for key in ["visual_entries", "shadow_entries"]:
			for entry in batch[key]:
				var multimesh := entry.multimesh as MultiMesh
				multimesh.instance_count = 0


func _update_enemy_visual_batches() -> void:
	if enemy_visual_batches.is_empty():
		return
	var grouped := {}
	for kind in BATCHED_ENEMY_KINDS:
		grouped[kind] = []
	for enemy in enemies:
		var kind := String(enemy.get("visual_batch_kind", ""))
		if kind != "":
			grouped[kind].append(enemy)
	for kind in grouped.keys():
		var batch := _ensure_enemy_visual_batch(kind)
		var batch_enemies: Array = grouped[kind]
		_update_enemy_visual_batch_entries(batch.visual_entries, batch_enemies, false)
		_update_enemy_visual_batch_entries(batch.shadow_entries, batch_enemies, true)


func _update_enemy_visual_batch_entries(entries: Array, batch_enemies: Array, shadow: bool) -> void:
	for entry in entries:
		var multimesh := entry.multimesh as MultiMesh
		multimesh.instance_count = batch_enemies.size()
	for enemy_index in range(batch_enemies.size()):
		var enemy: Dictionary = batch_enemies[enemy_index]
		var base_transform := _enemy_batch_shadow_transform(enemy) if shadow else _enemy_batch_visual_transform(enemy)
		for entry in entries:
			var multimesh := entry.multimesh as MultiMesh
			multimesh.set_instance_transform(enemy_index, base_transform * (entry.local_transform as Transform3D))


func _enemy_batch_visual_transform(enemy: Dictionary) -> Transform3D:
	var node := enemy.get("node") as Node3D
	var transform := node.transform if node != null else Transform3D.IDENTITY
	return transform * _enemy_batch_local_visual_transform(enemy)


func _enemy_batch_local_visual_transform(enemy: Dictionary) -> Transform3D:
	var transform := Transform3D.IDENTITY
	var visual_model := enemy.get("visual_model") as Node3D
	if visual_model != null:
		transform *= visual_model.transform
	var spin_model := enemy.get("spin_model") as Node3D
	if spin_model != null:
		transform *= spin_model.transform
	return transform


func _enemy_batch_shadow_transform(enemy: Dictionary) -> Transform3D:
	var node := enemy.node as Node3D
	return _tunnel_shadow_transform(enemy.pos, node.rotation.y, node.scale)


func _clear_hostile_bullets() -> void:
	bullet_manager.clear_hostile()


func _spawn_boss_core() -> void:
	var node := Node3D.new()
	node.name = "BossCore-%s" % EnemyUtil.display_name("boss_core").to_pascal_case()
	var model := _boss_core_caged_model(palette.boss_core)
	model.scale = Vector3.ONE * BOSS_CORE_VISUAL_SCALE
	node.add_child(model)
	node.position = _to_world(boss.center, 0.35)
	add_child(node)
	var enemy := EnemyUtil.create_boss_core(node, boss.center, palette.boss_core, BOSS_CORE_LIFE, BOSS_CORE_RADIUS)
	enemy.core_visual = node.find_child("boss-core-visual", true, false)
	enemy.wire_sphere = node.find_child("boss-core-wire-sphere", true, false)
	enemy.energy_shell = node.find_child("boss-core-energy-shell", true, false)
	enemy.core_mark = node.find_child("boss-core-inner-mark", true, false)
	enemy.rings_cw = node.find_children("boss-core-ring-cw*", "Node3D", true, false)
	enemy.rings_ccw = node.find_children("boss-core-ring-ccw*", "Node3D", true, false)
	enemy.gun_orbit = node.find_child("boss-core-gun-orbit", true, false)
	enemies.append(enemy)


func _boss_core_caged_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "boss-core-caged"
	var core_visual := Node3D.new()
	core_visual.name = "boss-core-visual"
	model.add_child(core_visual)
	core_visual.add_child(_boss_core_energy_shell())
	core_visual.add_child(_boss_core_wire_sphere(color))
	core_visual.add_child(_boss_core_caged_inner_mark(color))
	model.add_child(_boss_core_arc_ring(1.18, 0.014, 3, 3, 0.22, 0.0, "boss-core-ring-cw-inner", color.darkened(0.12), Vector3(0.18, 1.0, 0.36), 0.55, Vector3.FORWARD, 0.10))
	model.add_child(_boss_core_arc_ring(2.22, BOSS_CAGED_PRIMARY_RING_WIDTH, 4, 5, -0.30, 0.24, "boss-core-ring-ccw-primary", color.lerp(Color.WHITE, 0.58), Vector3(-0.45, 1.0, 0.20), -1.35, Vector3.RIGHT, -0.24, 0.23, 1.00))
	model.add_child(_boss_core_arc_ring(3.18, BOSS_CAGED_SECONDARY_RING_WIDTH, 5, 6, 0.24, -0.34, "boss-core-ring-cw-outer", color.lerp(Color.WHITE, 0.72), Vector3(0.38, 1.0, -0.52), 0.95, Vector3.FORWARD, 0.34, 0.20, 0.92))
	model.add_child(_boss_core_gun_orbit(color))
	return model


func _boss_core_wire_sphere(color: Color) -> Node3D:
	var shell := Node3D.new()
	shell.name = "boss-core-wire-sphere"
	var radius := 0.90
	var wire_color := color.lerp(Color.WHITE, 0.88)
	for longitude_index in range(5):
		var longitude_alpha := 0.26
		var longitude_emission := 0.72
		var longitude := _boss_core_ring_mesh(radius, 0.045, wire_color, longitude_alpha, longitude_emission)
		longitude.name = "boss-core-wire-longitude-%d" % longitude_index
		longitude.rotation = Vector3(PI * 0.5, TAU * float(longitude_index) / 5.0, 0.0)
		longitude.set_meta("wire_sphere_ring", true)
		longitude.set_meta("base_line_color", Color(wire_color.r, wire_color.g, wire_color.b, longitude_alpha))
		longitude.set_meta("base_emission", longitude_emission)
		shell.add_child(longitude)
	for latitude_index in range(5):
		var latitude_angle := lerpf(-0.78, 0.78, float(latitude_index) / 4.0)
		var latitude_radius := cos(latitude_angle) * radius
		var latitude_alpha := 0.21
		var latitude_emission := 0.58
		var latitude := _boss_core_ring_mesh(latitude_radius, 0.035, wire_color, latitude_alpha, latitude_emission)
		latitude.name = "boss-core-wire-latitude-%d" % latitude_index
		latitude.position.y = sin(latitude_angle) * radius
		latitude.set_meta("wire_sphere_ring", true)
		latitude.set_meta("base_line_color", Color(wire_color.r, wire_color.g, wire_color.b, latitude_alpha))
		latitude.set_meta("base_emission", latitude_emission)
		shell.add_child(latitude)
	return shell


func _boss_core_energy_shell() -> MeshInstance3D:
	var shell := MeshInstance3D.new()
	shell.name = "boss-core-energy-shell"
	var mesh := SphereMesh.new()
	mesh.radius = 0.86
	mesh.height = 1.72
	mesh.radial_segments = 24
	mesh.rings = 12
	shell.mesh = mesh
	shell.material_override = VisualMaterialsUtil.flat_face(Color.WHITE, 0.055, 0.20)
	return shell


func _boss_core_caged_inner_mark(color: Color) -> Node3D:
	var mark := Node3D.new()
	mark.name = "boss-core-inner-mark"
	mark.rotation = Vector3(0.18, 0.0, -0.24)
	var extent := 0.64
	var points := PackedVector3Array([
		Vector3(0.0, extent, 0.0), Vector3(-extent * 0.62, 0.0, -extent * 0.48),
		Vector3(extent * 0.62, 0.0, -extent * 0.48), Vector3(0.0, -extent, 0.0),
		Vector3(-extent * 0.42, 0.0, extent * 0.56), Vector3(extent * 0.42, 0.0, extent * 0.56),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 5, 0, 5, 4, 0, 4, 1, 3, 2, 1, 3, 5, 2, 3, 4, 5, 3, 1, 4])
	var face := _array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.lightened(0.08), 0.30, 0.62))
	face.name = "boss-core-inner-mark-face"
	mark.add_child(face)
	for edge in [[0, 1], [0, 2], [0, 4], [0, 5], [3, 1], [3, 2], [3, 4], [3, 5]]:
		var edge_mesh := _boss_core_edge(points[edge[0]], points[edge[1]], 0.018, color.lerp(Color.WHITE, 0.42), 0.42, 1.28)
		edge_mesh.name = "boss-core-inner-mark-edge"
		mark.add_child(edge_mesh, true)
	return mark


func _boss_core_arc_ring(radius: float, width: float, gap_start: int, gap_length: int, tilt_x: float, tilt_z: float, ring_name: String, color: Color, orbit_axis := Vector3.UP, orbit_speed := 0.0, precession_axis := Vector3.ZERO, precession_speed := 0.0, alpha := 0.26, emission := 1.05) -> Node3D:
	var ring := Node3D.new()
	ring.name = ring_name
	ring.position.y = maxf(0.0, radius - 0.30)
	ring.rotation = Vector3(tilt_x, 0.0, tilt_z)
	ring.set_meta("display_radius", radius)
	ring.set_meta("orbit_axis", (orbit_axis as Vector3).normalized())
	ring.set_meta("orbit_speed", orbit_speed)
	ring.set_meta("precession_axis", (precession_axis as Vector3).normalized())
	ring.set_meta("precession_speed", precession_speed)
	var segments := 24
	for index in range(segments):
		if posmod(index - gap_start, segments) < gap_length:
			continue
		var a := TAU * float(index) / float(segments)
		var b := TAU * float(index + 1) / float(segments)
		var pa := Vector3(cos(a) * radius, 0.0, sin(a) * radius)
		var pb := Vector3(cos(b) * radius, 0.0, sin(b) * radius)
		ring.add_child(_boss_core_edge(pa, pb, width, color, alpha, emission))
	return ring


func _boss_core_gun_orbit(color: Color) -> Node3D:
	var orbit := Node3D.new()
	orbit.name = "boss-core-gun-orbit"
	for index in range(4):
		var angle := randf() * TAU
		var tilt_x := randf_range(-0.55, 0.55)
		var tilt_z := randf_range(-0.55, 0.55)
		var gun := Node3D.new()
		gun.set_meta("orbit_angle", angle)
		gun.set_meta("orbit_tilt_x", tilt_x)
		gun.set_meta("orbit_tilt_z", tilt_z)
		gun.position = _boss_core_gun_orbit_position(angle, tilt_x, tilt_z)
		gun.rotation.y = -Vector2(gun.position.x, gun.position.z).angle() + PI * 0.5
		orbit.add_child(gun)
		_add_zako4_box_part(gun, Vector3.ZERO, Vector3(0.16, 0.11, 0.22), color.darkened(0.12), 0.009, 0.22, 0.95)
	return orbit


func _boss_core_gun_orbit_position(angle: float, tilt_x: float, tilt_z: float) -> Vector3:
	var flat := Vector3(cos(angle) * BOSS_CORE_GUN_ORBIT_RADIUS, 0.0, sin(angle) * BOSS_CORE_GUN_ORBIT_RADIUS)
	return Basis.from_euler(Vector3(tilt_x, 0.0, tilt_z)) * flat


func _boss_core_ring_mesh(radius: float, width: float, color: Color, alpha: float, emission: float) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var inner_radius := maxf(0.02, radius - width)
	var segments := 48
	for segment in range(segments):
		var angle_a := TAU * float(segment) / float(segments)
		var angle_b := TAU * float(segment + 1) / float(segments)
		var base_index := vertices.size()
		vertices.append(Vector3(cos(angle_a) * inner_radius, 0.0, sin(angle_a) * inner_radius))
		vertices.append(Vector3(cos(angle_a) * radius, 0.0, sin(angle_a) * radius))
		vertices.append(Vector3(cos(angle_b) * radius, 0.0, sin(angle_b) * radius))
		vertices.append(Vector3(cos(angle_b) * inner_radius, 0.0, sin(angle_b) * inner_radius))
		indices.append_array(PackedInt32Array([
			base_index, base_index + 1, base_index + 2,
			base_index, base_index + 2, base_index + 3,
		]))
	var ring := _array_mesh(vertices, indices, VisualMaterialsUtil.outline(color, alpha, emission))
	ring.set_meta("band_width", width)
	return ring


func _boss_core_edge(a: Vector3, b: Vector3, width: float, color: Color, alpha := 0.26, emission := 1.05) -> MeshInstance3D:
	var direction := b - a
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = VisualMaterialsUtil.outline(color, alpha, emission)
	return edge


func _boss_turret_sequence() -> Array[String]:
	var turret_kinds: Array[String] = ["boss_turret_t1", "boss_turret_t2"]
	if game_state.arcade_rank > 6:
		turret_kinds.append("boss_turret_t2")
		turret_kinds.append("boss_turret_t3")
	if game_state.arcade_rank > 11:
		turret_kinds.append("boss_turret_t1")
		turret_kinds.append("boss_turret_t3")
	if game_state.arcade_rank > 16:
		turret_kinds.append("boss_turret_t2")
		turret_kinds.append("boss_turret_t3")
	return turret_kinds


func _spawn_boss_turret(kind: String) -> void:
	var color: Color = palette[kind]
	var node := Node3D.new()
	node.name = "%s-%s" % [kind, EnemyUtil.display_name(kind).to_snake_case()]
	node.add_child(_boss_t_stepped_citadel_model(kind, color))
	node.set_meta("turret_overall_scale", BOSS_TURRET_OVERALL_SCALE)
	var occupied_positions: Array[Vector2] = []
	for existing in enemies:
		if String(existing.get("kind", "")).begins_with("boss_turret") and existing.get("life", 0) > 0:
			occupied_positions.append(existing.pos as Vector2)
	var pos := boss.turret_spawn_pos(player.pos, FIELD_W, FIELD_H, occupied_positions)
	var offset := pos - boss.center
	node.position = _to_world(pos, BOSS_TURRET_VISUAL_HEIGHT)
	add_child(node)
	var connection_line := _boss_connection_ribbon_runtime_model(boss.center, pos, enemies.size())
	add_child(connection_line)
	var enemy := EnemyUtil.create_boss_turret(kind, node, pos, color, BOSS_TURRET_LIFE, _boss_turret_radius(kind), offset)
	enemy.connection_line = connection_line
	enemy.body_visual = node.find_child("boss-t-body-visual", true, false)
	enemy.body_faces = _boss_t_body_faces(enemy.body_visual as Node3D)
	enemy.tripod_base = node.find_child("boss-t-tripod-base", true, false)
	enemy.slow_gun = node.find_child("boss-t-slow-gun", true, false)
	enemy.slow_gun_visual = node.find_child("boss-t-slow-gun-cube", true, false)
	enemy.rapid_guns = node.find_children("boss-t1-rapid-gun*", "Node3D", true, false)
	enemy.opposing_gun = node.find_child("boss-t2-opposing-gun", true, false)
	enemy.direction_guns = node.find_children("boss-t2-direction-gun*", "Node3D", true, false)
	enemy.emitters = node.find_children("boss-t3-emitter*", "Node3D", true, false)
	_lock_spawn_collision(enemy)
	enemies.append(enemy)


func _boss_turret_radius(kind: String) -> float:
	return BOSS_TURRET_RADII.get(kind, BOSS_TURRET_RADIUS)


func _boss_t_body_faces(root: Node3D) -> Array[Node]:
	var faces: Array[Node] = []
	for mesh_node in root.find_children("*", "MeshInstance3D", true, false):
		if (mesh_node as MeshInstance3D).has_meta("base_alpha"):
			faces.append(mesh_node)
	return faces


func _boss_t_stepped_citadel_model(kind: String, color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "boss-t-stepped-citadel"
	model.scale = Vector3.ONE * BOSS_TURRET_OVERALL_SCALE
	model.set_meta("overall_scale", BOSS_TURRET_OVERALL_SCALE)
	var frame_color: Color = palette.boss_core
	var body_visual := Node3D.new()
	body_visual.name = "boss-t-body-visual"
	body_visual.scale = Vector3.ONE * BOSS_TURRET_VISUAL_SCALE
	body_visual.set_meta("visual_scale", BOSS_TURRET_VISUAL_SCALE)
	model.add_child(_boss_t_tripod_base_model(frame_color))
	model.add_child(body_visual)
	var wall_height := 0.30
	if kind == "boss_turret_t1":
		_add_boss_t_rapid_rail_body(body_visual, frame_color)
		_add_boss_t1_mounts(model, color, frame_color, wall_height)
	elif kind == "boss_turret_t2":
		_add_boss_t_opposing_frame_body(body_visual, frame_color)
		_add_boss_t2_mounts(model, color, frame_color, wall_height)
	else:
		_add_boss_t_burst_triad_body(body_visual, frame_color)
		_add_boss_t3_emitters(model, color, wall_height)
	return model


func _add_boss_t_rapid_rail_body(root: Node3D, color: Color) -> void:
	var body := Node3D.new()
	body.name = "boss-t-rapid-rail-body"
	root.add_child(body)
	var rail_color := color.lightened(0.04)
	_add_boss_t_box_part(body, Vector3(0.0, 0.04, 0.0), Vector3(0.30, 0.26, 1.70), rail_color, 0.28, 0.014)
	for side in [-1.0, 1.0]:
		_add_boss_t_box_part(body, Vector3(side * 0.42, 0.09, 0.0), Vector3(0.12, 0.20, 1.42), rail_color.lightened(0.05), 0.24, 0.012)
		body.add_child(_subtle_glow_edge(Vector3(side * 0.55, 0.18, -0.70), Vector3(side * 0.24, 0.18, 0.70), rail_color.lightened(0.16), 0.010))
	_add_boss_t_box_part(body, Vector3(0.0, 0.15, -0.78), Vector3(1.00, 0.12, 0.16), rail_color.darkened(0.04), 0.22, 0.012)
	_add_boss_t_box_part(body, Vector3(0.0, 0.16, 0.82), Vector3(0.56, 0.12, 0.18), rail_color.lightened(0.08), 0.24, 0.012)


func _add_boss_t_opposing_frame_body(root: Node3D, color: Color) -> void:
	var body := Node3D.new()
	body.name = "boss-t-opposing-frame-body"
	root.add_child(body)
	var frame_color := color.lightened(0.02)
	_add_boss_t_box_part(body, Vector3(0.0, 0.04, 0.0), Vector3(1.55, 0.22, 0.24), frame_color, 0.27, 0.014)
	_add_boss_t_box_part(body, Vector3(0.0, 0.11, 0.0), Vector3(0.44, 0.22, 1.18), frame_color.darkened(0.03), 0.24, 0.012)
	for side in [-1.0, 1.0]:
		_add_boss_t_box_part(body, Vector3(side * 0.82, 0.13, 0.0), Vector3(0.30, 0.18, 0.48), frame_color.lightened(0.06), 0.24, 0.012)
		body.add_child(_subtle_glow_edge(Vector3(side * 0.22, 0.23, -0.42), Vector3(side * 0.78, 0.23, 0.24), frame_color.lightened(0.17), 0.011))
		body.add_child(_subtle_glow_edge(Vector3(side * 0.22, 0.23, 0.42), Vector3(side * 0.78, 0.23, -0.24), frame_color.lightened(0.17), 0.011))


func _add_boss_t_burst_triad_body(root: Node3D, color: Color) -> void:
	var body := Node3D.new()
	body.name = "boss-t-burst-triad-body"
	root.add_child(body)
	var triad_color := color.lightened(0.06)
	_add_boss_t_tri_prism(body, 0.88, 0.26, triad_color)
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		var pad_position := Vector3(cos(angle) * 0.44, 0.20, sin(angle) * 0.44)
		var pad := Node3D.new()
		pad.position = pad_position
		pad.rotation.y = -angle + PI * 0.5
		body.add_child(pad)
		_add_boss_t_box_part(pad, Vector3.ZERO, Vector3(0.26, 0.12, 0.42), triad_color.lightened(0.06), 0.26, 0.012)


func _add_boss_t_tri_prism(root: Node3D, radius: float, height: float, color: Color) -> void:
	var points := PackedVector3Array()
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		points.append(Vector3(cos(angle) * radius, height, sin(angle) * radius))
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		points.append(Vector3(cos(angle) * radius * 0.86, 0.0, sin(angle) * radius * 0.86))
	var indices := PackedInt32Array([
		0, 1, 2,
		3, 5, 4,
		0, 3, 4, 0, 4, 1,
		1, 4, 5, 1, 5, 2,
		2, 5, 3, 2, 3, 0,
	])
	var face := _array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.26, 0.58))
	face.name = "boss-t-body-face"
	face.set_meta("base_color", color)
	face.set_meta("base_alpha", 0.26)
	face.set_meta("base_emission", 0.58)
	face.set_meta("hit_alpha_gain", 0.32)
	face.set_meta("hit_emission", 2.10)
	face.set_meta("hit_whiten", 0.54)
	root.add_child(face, true)
	for edge in [
		[0, 1], [1, 2], [2, 0],
		[3, 4], [4, 5], [5, 3],
		[0, 3], [1, 4], [2, 5],
	]:
		root.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color, 0.014))


func _boss_t_tripod_base_model(color: Color) -> Node3D:
	var base := Node3D.new()
	base.name = "boss-t-tripod-base"
	var base_color := color.lerp(Color.WHITE, 0.18)
	_add_boss_t_base_hub(base, base_color.lightened(0.06))
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		var inner := Vector3(cos(angle) * 0.16, -0.075, sin(angle) * 0.16)
		var outer := Vector3(cos(angle) * 0.86, -0.130, sin(angle) * 0.86)
		_add_boss_t_base_leg_panel(base, inner, outer, angle, base_color)
		_add_boss_t_base_foot(base, outer, angle, base_color.lightened(0.04))
	return base


func _add_boss_t_base_hub(root: Node3D, color: Color) -> void:
	var points := PackedVector3Array()
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		points.append(Vector3(cos(angle) * 0.22, -0.072, sin(angle) * 0.22))
	var hub := _array_mesh(points, PackedInt32Array([0, 1, 2]), VisualMaterialsUtil.flat_face(color, 0.13, 0.38))
	hub.name = "boss-t-tripod-hub"
	root.add_child(hub)
	for edge in [[0, 1], [1, 2], [2, 0]]:
		root.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.04), 0.012))


func _add_boss_t_base_leg_panel(root: Node3D, inner: Vector3, outer: Vector3, angle: float, color: Color) -> void:
	var side := Vector3(-sin(angle), 0.0, cos(angle))
	var inner_width := 0.070
	var outer_width := 0.180
	var points := PackedVector3Array([
		inner - side * inner_width,
		inner + side * inner_width,
		outer + side * outer_width,
		outer - side * outer_width,
	])
	var panel := _array_mesh(points, PackedInt32Array([0, 1, 2, 0, 2, 3]), VisualMaterialsUtil.flat_face(color, 0.115, 0.34))
	panel.name = "boss-t-tripod-leg-panel"
	panel.set_meta("tripod_leg_panel", true)
	root.add_child(panel)
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0]]:
		root.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.06), 0.010))
	root.add_child(_subtle_glow_edge((points[0] + points[1]) * 0.5, (points[2] + points[3]) * 0.5, color.lightened(0.02), 0.008))


func _add_boss_t_base_foot(root: Node3D, center: Vector3, angle: float, color: Color) -> void:
	var foot := MeshInstance3D.new()
	foot.name = "boss-t-tripod-foot"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.22, 0.018, 0.075)
	foot.mesh = mesh
	foot.position = center
	foot.rotation.y = -angle + PI * 0.5
	foot.material_override = VisualMaterialsUtil.flat_face(color, 0.18, 0.42)
	root.add_child(foot)


func _add_boss_t1_mounts(root: Node3D, color: Color, frame_color: Color, height: float) -> void:
	for side in [-1.0, 1.0]:
		var gun := Node3D.new()
		gun.name = "boss-t1-rapid-gun-left" if side < 0.0 else "boss-t1-rapid-gun-right"
		gun.position = Vector3(side * 0.42, height * 0.66, 0.18)
		gun.set_meta("recoil_base_position", gun.position)
		root.add_child(gun)
		gun.add_child(_boss_t1_rapid_prism_gun(color.lightened(0.12)))
	_add_boss_t_slow_gun(root, frame_color, height)


func _add_boss_t2_mounts(root: Node3D, color: Color, frame_color: Color, height: float) -> void:
	_add_boss_t_slow_gun(root, frame_color, height)
	var opposing_gun := Node3D.new()
	opposing_gun.name = "boss-t2-opposing-gun"
	opposing_gun.position.y = height * BOSS_T2_OPPOSING_GUN_HEIGHT_RATIO
	root.add_child(opposing_gun)
	for direction in [-1.0, 1.0]:
		var gun := Node3D.new()
		gun.name = "boss-t2-direction-gun-back" if direction < 0.0 else "boss-t2-direction-gun-front"
		gun.position.z = -direction * 0.28
		gun.rotation.y = 0.0 if direction > 0.0 else PI
		gun.set_meta("recoil_base_position", gun.position)
		opposing_gun.add_child(gun)
		gun.add_child(_boss_t2_direction_prism_gun(color.lightened(0.12)))


func _add_boss_t_slow_gun(root: Node3D, color: Color, height: float) -> void:
	var slow_gun := Node3D.new()
	slow_gun.name = "boss-t-slow-gun"
	slow_gun.position = Vector3(0.0, height * 0.72, -0.96)
	root.add_child(slow_gun)
	var cube := Node3D.new()
	cube.name = "boss-t-slow-gun-cube"
	cube.set_meta("recoil_base_position", cube.position)
	slow_gun.add_child(cube)
	_add_boss_t_box_part(cube, Vector3.ZERO, Vector3(0.24, 0.24, 0.24), color.lightened(0.04), 0.30, BOSS_T_SLOW_GUN_EDGE_WIDTH)


func _add_boss_t3_emitters(root: Node3D, color: Color, height: float) -> void:
	for index in [1, 2, 3]:
		var angle := TAU * float(index) / 4.0
		var emitter := Node3D.new()
		emitter.name = "boss-t3-emitter-%d" % index
		emitter.position = Vector3(sin(angle) * 0.72, height * 0.72, -cos(angle) * 0.72)
		emitter.rotation.y = -angle
		emitter.set_meta("recoil_base_position", emitter.position)
		root.add_child(emitter)
		emitter.add_child(_boss_t_prism_gun(color.lightened(0.14)))


func _boss_t_prism_gun(color: Color) -> Node3D:
	var gun := Node3D.new()
	gun.name = "boss-t-prism-gun"
	var points := PackedVector3Array([
		Vector3(0.0, 0.14, -0.34), Vector3(-0.18, 0.0, 0.18),
		Vector3(0.18, 0.0, 0.18), Vector3(0.0, -0.10, 0.08),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	gun.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.38, 0.68)))
	for edge in [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]]:
		gun.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color, 0.012))
	return gun


func _boss_t1_rapid_prism_gun(color: Color) -> Node3D:
	var gun := Node3D.new()
	gun.name = "boss-gun1-needle-prism"
	var points := PackedVector3Array([
		Vector3(0.0, 0.17, -0.43),
		Vector3(-0.16, 0.0, 0.18),
		Vector3(0.16, 0.0, 0.18),
		Vector3(0.0, -0.11, 0.06),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	gun.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.05), 0.26, 0.54)))
	for edge in [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]:
		gun.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.04), BOSS_T_RAPID_GUN_EDGE_WIDTH))
	gun.add_child(_subtle_glow_edge(Vector3(-0.22, 0.02, 0.24), Vector3(0.22, 0.02, 0.24), color.lightened(0.04), BOSS_T_RAPID_GUN_EDGE_WIDTH))
	return gun


func _boss_t2_direction_prism_gun(color: Color) -> Node3D:
	var gun := Node3D.new()
	gun.name = "boss-gun2-opposing-prism"
	var points := PackedVector3Array([
		Vector3(0.0, 0.15, -0.36),
		Vector3(-0.22, 0.0, 0.16),
		Vector3(0.22, 0.0, 0.16),
		Vector3(0.0, -0.11, 0.08),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	gun.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.02), 0.28, 0.58)))
	for edge in [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]:
		gun.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.03), BOSS_T_DIRECTION_GUN_EDGE_WIDTH))
	gun.add_child(_subtle_glow_edge(Vector3(-0.20, 0.02, 0.28), Vector3(0.20, 0.02, 0.28), color.lightened(0.03), BOSS_T_DIRECTION_GUN_EDGE_WIDTH))
	return gun


func _add_boss_t_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color, alpha: float, edge_width: float) -> void:
	var half := size * 0.5
	var points := PackedVector3Array([
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	])
	var indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	])
	var face := _array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, alpha, 0.58))
	face.name = "boss-t-body-face"
	face.set_meta("base_color", color)
	face.set_meta("base_alpha", alpha)
	face.set_meta("base_emission", 0.58)
	face.set_meta("hit_alpha_gain", 0.30)
	face.set_meta("hit_emission", 2.05)
	face.set_meta("hit_whiten", 0.52)
	root.add_child(face, true)
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		root.add_child(_subtle_glow_edge(points[edge[0]], points[edge[1]], color, edge_width))


func _boss_connection_ribbon_trial_model(variant: int) -> Node3D:
	var model := Node3D.new()
	model.name = "boss-connection-ribbon-trial-%d" % variant
	var core_anchor := Vector3(-2.2, 0.10, 0.0)
	var turret_anchor := Vector3(2.35, 0.16, 0.0)
	var core := _boss_core_caged_model(palette.boss_core)
	core.name = "boss-connection-trial-core"
	core.position = core_anchor
	core.scale = Vector3.ONE * 0.38
	model.add_child(core)
	var turret := _boss_t_stepped_citadel_model("boss_turret_t1", palette.boss_turret_t1)
	turret.name = "boss-connection-trial-turret"
	turret.position = turret_anchor
	turret.scale = Vector3.ONE * 0.48
	model.add_child(turret)
	var points := _boss_connection_trial_points(core_anchor, turret_anchor, variant)
	var ribbon_color := Color(0.82, 0.96, 1.0)
	if variant == 0:
		model.add_child(_boss_connection_ribbon_mesh(points, 0.11, ribbon_color, 0.15, 0.48))
		model.add_child(_boss_connection_ribbon_mesh(_boss_connection_offset_points(points, Vector3(0.0, 0.07, 0.05)), 0.045, Color.WHITE, 0.11, 0.62))
	elif variant == 1:
		for index in range(points.size() - 1):
			model.add_child(_boss_connection_ribbon_mesh([points[index], points[index + 1]], 0.085, ribbon_color.lerp(Color.WHITE, 0.18), 0.13, 0.42))
		for index in range(1, points.size() - 1):
			model.add_child(_boss_connection_node_marker(points[index], index))
	else:
		model.add_child(_boss_connection_ribbon_mesh(points, 0.13, ribbon_color.lerp(Color.WHITE, 0.24), 0.16, 0.50))
		model.add_child(_boss_connection_ribbon_mesh(_boss_connection_offset_points(points, Vector3(0.0, -0.05, -0.06)), 0.055, Color.WHITE, 0.10, 0.72))
	return model


func _boss_connection_ribbon_runtime_model(start: Vector2, finish: Vector2, seed: int) -> Node3D:
	var root := Node3D.new()
	root.name = "BossCoreConnection"
	root.set_meta("connection_seed", seed)
	var points := _boss_connection_runtime_points(start, finish, seed)
	var ribbon_color := Color(0.82, 0.96, 1.0)
	var main := _boss_connection_ribbon_mesh(points, 0.11, ribbon_color, 0.15, 0.48)
	main.name = "BossCoreConnectionRibbonMain"
	root.add_child(main)
	var highlight := _boss_connection_ribbon_mesh(_boss_connection_offset_points(points, Vector3(0.0, 0.07, 0.05)), 0.045, Color.WHITE, 0.11, 0.62)
	highlight.name = "BossCoreConnectionRibbonHighlight"
	root.add_child(highlight)
	return root


func _boss_connection_runtime_points(start: Vector2, finish: Vector2, seed: int) -> Array[Vector3]:
	return _boss_connection_trial_points(Vector3(start.x, 0.10, start.y), Vector3(finish.x, 0.16, finish.y), seed)


func _boss_connection_trial_points(start: Vector3, finish: Vector3, variant: int) -> Array[Vector3]:
	var points: Array[Vector3] = []
	var normalized_variant := posmod(variant, 3)
	var distance := Vector2(start.x, start.z).distance_to(Vector2(finish.x, finish.z))
	var count := 8 if normalized_variant != 1 else 6
	if normalized_variant == 0:
		count = clampi(8 + int(distance * 0.75), 8, 14)
	var wave_cycles := lerpf(1.35, 2.35, clampf((distance - 3.0) / 5.0, 0.0, 1.0))
	var lateral_scale := lerpf(1.0, 1.55, clampf((distance - 3.0) / 5.0, 0.0, 1.0))
	for index in range(count):
		var t := float(index) / float(count - 1)
		var base := start.lerp(finish, t)
		var wave := sin(t * TAU * (wave_cycles if normalized_variant == 0 else 1.35 + 0.18 * float(normalized_variant)) + float(variant) * 0.9)
		var jitter := sin(float(index * 37 + variant * 11)) * 0.5 + 0.5
		if normalized_variant == 0:
			var end_fade := sin(t * PI)
			base.y += (wave * 0.46 + end_fade * 0.34) * end_fade * lateral_scale
			base.z += cos(t * TAU * (wave_cycles + 0.35)) * lerpf(0.36, 0.64, jitter) * end_fade * lateral_scale
		elif normalized_variant == 1:
			base.y += sin(t * PI) * 0.34 + (jitter - 0.5) * 0.26
			base.z += ((jitter - 0.5) * 0.72)
		else:
			base.y += sin(t * PI) * 0.86 + wave * 0.10
			base.z += sin(t * TAU * 0.85 + 0.7) * 0.22
		points.append(base)
	return points


func _boss_connection_offset_points(points: Array[Vector3], offset: Vector3) -> Array[Vector3]:
	var offset_points: Array[Vector3] = []
	for point in points:
		offset_points.append(point + offset)
	return offset_points


func _boss_connection_node_marker(position: Vector3, index: int) -> MeshInstance3D:
	var marker := MeshInstance3D.new()
	marker.name = "boss-connection-node-%d" % index
	if index % 2 == 0:
		var mesh := SphereMesh.new()
		mesh.radius = 0.070
		mesh.height = 0.140
		mesh.radial_segments = 8
		mesh.rings = 4
		marker.mesh = mesh
	else:
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.13, 0.13, 0.13)
		marker.mesh = mesh
		marker.rotation = Vector3(0.26, 0.48, 0.18)
	marker.position = position
	marker.material_override = VisualMaterialsUtil.flat_face(Color(0.88, 0.98, 1.0), 0.24, 0.54)
	return marker


func _boss_connection_ribbon_mesh(points: Array[Vector3], width: float, color: Color, alpha: float, emission: float) -> MeshInstance3D:
	var verts := PackedVector3Array()
	var indices := PackedInt32Array()
	for index in range(points.size()):
		var current := points[index]
		var previous := points[maxi(0, index - 1)]
		var next := points[mini(points.size() - 1, index + 1)]
		var tangent := (next - previous).normalized()
		var side := tangent.cross(Vector3.UP).normalized()
		if side.is_zero_approx():
			side = Vector3.RIGHT
		var twist := sin(float(index) * 1.73 + width * 19.0) * 0.35
		side = side.rotated(tangent, twist)
		var local_width := width * (0.82 + 0.24 * sin(float(index) * 1.11 + 0.4))
		verts.append(current - side * local_width * 0.5)
		verts.append(current + side * local_width * 0.5)
		if index < points.size() - 1:
			var base := index * 2
			indices.append_array([base, base + 1, base + 2, base + 1, base + 3, base + 2])
	return _array_mesh(verts, indices, VisualMaterialsUtil.overlay_face(color, alpha, emission, 7))


func _spawn_enemy_destroy_effect(pos: Vector2, color: Color, radius: float, accent_color := Color.TRANSPARENT, accent_ratio := 0.0) -> void:
	var burst := Node3D.new()
	burst.name = "EnemyDestroyEffect"
	burst.set_meta("effect_type", "enemy_destroy")
	var size_factor := clampf(radius / 0.36, 0.75, 3.0)
	var piece_count := clampi(4 + int(ceil(size_factor * 4.0)), 6, 18)
	var shard_mat := _transparent_material(Color(color.r, color.g, color.b, clampf(0.38 + size_factor * 0.10, 0.42, 0.76)), 0.95 + size_factor * 0.22)
	var plate_mat := _transparent_material(Color(color.r, color.g, color.b, clampf(0.30 + size_factor * 0.09, 0.34, 0.66)), 0.86 + size_factor * 0.18)
	var accent_shard_mat := _transparent_material(Color(accent_color.r, accent_color.g, accent_color.b, 0.64), 1.16)
	var accent_plate_mat := _transparent_material(Color(accent_color.r, accent_color.g, accent_color.b, 0.50), 1.02)
	var accent_step := maxi(1, roundi(1.0 / accent_ratio)) if accent_ratio > 0.0 else 0
	for i in range(piece_count):
		var piece := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		var is_plate := i % 2 == 0
		var uses_accent := accent_step > 0 and i % accent_step == 0
		piece.set_meta("destroy_palette", "accent" if uses_accent else "base")
		if is_plate:
			piece.name = "EnemyDestroyPlate"
			piece.set_meta("destroy_piece", "plate")
			var plate_size := randf_range(0.24, 0.42) * sqrt(size_factor)
			mesh.size = Vector3(plate_size, 0.010, plate_size)
			piece.material_override = accent_plate_mat if uses_accent else plate_mat
		else:
			piece.name = "EnemyDestroyShard"
			piece.set_meta("destroy_piece", "shard")
			var long_side := randf_range(0.24, 0.48) * size_factor
			var short_side := randf_range(0.08, 0.16) * sqrt(size_factor)
			mesh.size = Vector3(short_side, randf_range(0.025, 0.055), long_side)
			piece.material_override = accent_shard_mat if uses_accent else shard_mat
		piece.mesh = mesh
		var angle := TAU * float(i) / float(piece_count) + randf_range(-0.22, 0.22)
		var dir := Vector2.from_angle(angle)
		piece.position = _to_world(dir * randf_range(0.04, 0.20) * size_factor, 0.36 + randf_range(-0.10, 0.14))
		piece.rotation = Vector3(randf_range(-0.35, 0.35), angle + randf_range(-0.45, 0.45), randf_range(-0.30, 0.30))
		burst.add_child(piece)
		var target_distance := randf_range(1.10, 2.30) * size_factor
		piece.set_meta("target_distance", target_distance)
		var duration := randf_range(0.38, 0.62) * clampf(sqrt(size_factor), 0.85, 1.40)
		var tween := create_tween()
		tween.parallel().tween_property(piece, "position", _to_world(dir * target_distance, randf_range(0.16, 0.36)), duration)
		tween.parallel().tween_property(piece, "rotation", piece.rotation + Vector3(randf_range(-2.2, 2.2), randf_range(1.6, 4.4), randf_range(-2.2, 2.2)), duration)
		tween.parallel().tween_property(piece, "scale", Vector3(randf_range(0.45, 0.85), 0.18, randf_range(0.45, 0.85)), duration)
	burst.position = _to_world(pos, 0.0)
	add_child(burst)
	var fade := create_tween()
	var fade_duration := 0.76 * clampf(sqrt(size_factor), 0.85, 1.45)
	fade.parallel().tween_property(shard_mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), fade_duration)
	fade.parallel().tween_property(plate_mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), fade_duration)
	fade.parallel().tween_property(accent_shard_mat, "albedo_color", Color(accent_color.r, accent_color.g, accent_color.b, 0.0), fade_duration)
	fade.parallel().tween_property(accent_plate_mat, "albedo_color", Color(accent_color.r, accent_color.g, accent_color.b, 0.0), fade_duration)
	fade.tween_callback(burst.queue_free)


func _spawn_hit_effect(pos: Vector2, color: Color, impact_direction := Vector2.RIGHT) -> void:
	var flash := Node3D.new()
	flash.name = "HitEffect"
	var tail_mat := _transparent_material(Color(color.r, color.g, color.b, 0.32), 0.48)
	tail_mat.emission_enabled = false
	var tip_color := color.lerp(Color(1.0, 0.92, 0.42), 0.35).lightened(0.16)
	var tip_mat := _transparent_material(Color(tip_color, 0.86), 2.42)
	flash.position = _to_world(pos, 0.42)
	var incoming := impact_direction.normalized()
	if incoming.is_zero_approx():
		incoming = Vector2.RIGHT
	flash.set_meta("impact_direction", incoming)
	flash.scale = Vector3.ZERO
	var plate_count := randi_range(2, 3)
	for i in range(plate_count):
		var angle: float
		if i < 2:
			angle = incoming.angle() + PI + randf_range(-0.52, 0.52)
		else:
			angle = incoming.angle() + randf_range(PI * 0.34, PI * 1.66)
		var direction := Vector2.from_angle(angle)
		var spark_length := randf_range(0.336, 0.630)
		var tail_length := spark_length * randf_range(0.58, 0.68)
		var tip_length := spark_length - tail_length
		var gap := randf_range(0.025, 0.053)
		var width := randf_range(0.026, 0.044)
		var tail := MeshInstance3D.new()
		tail.name = "HitEffectTail"
		tail.set_meta("hit_piece", "tail")
		tail.set_meta("spark_direction", direction)
		var tail_mesh := BoxMesh.new()
		tail_mesh.size = Vector3(width, 0.006, tail_length)
		tail.mesh = tail_mesh
		tail.position = _to_world(direction * (gap + tail_length * 0.5), randf_range(0.00, 0.045))
		tail.rotation = Vector3(randf_range(-0.16, 0.16), -angle + PI * 0.5, randf_range(-0.13, 0.13))
		tail.material_override = tail_mat
		flash.add_child(tail)
		var tip := MeshInstance3D.new()
		tip.name = "HitEffectTip"
		tip.set_meta("hit_piece", "tip")
		tip.set_meta("spark_direction", direction)
		var tip_mesh := BoxMesh.new()
		tip_mesh.size = Vector3(width * 0.72, 0.006, tip_length)
		tip.mesh = tip_mesh
		tip.position = _to_world(direction * (gap + tail_length + tip_length * 0.5), randf_range(0.00, 0.045))
		tip.rotation = tail.rotation
		tip.material_override = tip_mat
		flash.add_child(tip)
	add_child(flash)
	var tween := create_tween()
	tween.parallel().tween_property(flash, "scale", Vector3.ONE * randf_range(1.35, 2.05), randf_range(0.14, 0.22))
	tween.parallel().tween_property(flash, "rotation", flash.rotation + Vector3(0.0, randf_range(-0.18, 0.18), 0.0), 0.20)
	tween.parallel().tween_property(tail_mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), randf_range(0.14, 0.22))
	tween.parallel().tween_property(tip_mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), randf_range(0.14, 0.22))
	tween.tween_callback(flash.queue_free)


func _spawn_boss_core_unlock_effect(pos: Vector2) -> void:
	var effect := Node3D.new()
	effect.name = "BossCoreUnlockEffect"
	effect.position = _to_world(pos, 0.64)
	effect.set_meta("effect_type", "boss_core_unlock")
	add_child(effect)

	var base_color: Color = palette.boss_core.lerp(Color.WHITE, 0.72)
	for i in range(3):
		var ring := MeshInstance3D.new()
		ring.name = "BossCoreUnlockRing"
		ring.set_meta("unlock_piece", "ring")
		var mesh := TorusMesh.new()
		var radius := 0.46 + float(i) * 0.16
		mesh.inner_radius = radius
		mesh.outer_radius = radius + 0.030 + float(i) * 0.006
		mesh.rings = 48
		mesh.ring_segments = 6
		ring.mesh = mesh
		var alpha := 0.62 - float(i) * 0.11
		var material := _boss_core_unlock_material(Color(base_color.r, base_color.g, base_color.b, alpha), 2.30 - float(i) * 0.22)
		ring.material_override = material
		ring.rotation = Vector3(
			deg_to_rad(64.0 + float(i) * 12.0),
			deg_to_rad(18.0 + float(i) * 37.0),
			deg_to_rad(-12.0 + float(i) * 24.0)
		)
		ring.scale = Vector3.ONE * (0.50 + float(i) * 0.08)
		effect.add_child(ring)
		var duration := 0.46 + float(i) * 0.08
		var delay := float(i) * 0.035
		var motion := create_tween()
		motion.tween_interval(delay)
		motion.tween_property(ring, "scale", Vector3.ONE * (2.58 + float(i) * 0.41), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		motion.parallel().tween_property(ring, "rotation:y", ring.rotation.y + 0.55 + float(i) * 0.18, duration)
		motion.parallel().tween_property(material, "albedo_color", Color(base_color.r, base_color.g, base_color.b, 0.0), duration)

	var flash := MeshInstance3D.new()
	flash.name = "BossCoreUnlockFlash"
	flash.set_meta("unlock_piece", "phase_flash")
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.98 * BOSS_CORE_VISUAL_SCALE
	flash_mesh.height = 1.96 * BOSS_CORE_VISUAL_SCALE
	flash_mesh.radial_segments = 16
	flash_mesh.rings = 8
	flash.mesh = flash_mesh
	var flash_material := _boss_core_unlock_material(Color(0.92, 1.0, 1.0, 0.26), 2.80)
	flash.material_override = flash_material
	flash.scale = Vector3.ONE * 0.65
	effect.add_child(flash)
	var flash_tween := create_tween()
	flash_tween.parallel().tween_property(flash, "scale", Vector3.ONE * 1.18, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash_tween.parallel().tween_property(flash_material, "albedo_color", Color(0.92, 1.0, 1.0, 0.0), 0.28)

	var cleanup := create_tween()
	cleanup.tween_interval(0.72)
	cleanup.tween_callback(effect.queue_free)


func _boss_core_unlock_material(color: Color, emission: float) -> StandardMaterial3D:
	var material := _transparent_material(color, emission)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.render_priority = BOSS_CORE_UNLOCK_RENDER_PRIORITY
	return material


func _boss_light_leak_band(length: float, width_scale: float) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var station_count := 9
	for station in range(station_count):
		var progress := float(station) / float(station_count - 1)
		var width := lerpf(0.036, 0.250, pow(progress, 1.25)) * width_scale * BOSS_CORE_VISUAL_SCALE
		var z := length * progress
		vertices.append(Vector3(-width * 0.5, 0.0, z))
		vertices.append(Vector3(width * 0.5, 0.0, z))
		uvs.append(Vector2(0.0, progress))
		uvs.append(Vector2(1.0, progress))
		if station > 0:
			var previous := (station - 1) * 2
			var current := station * 2
			indices.append(previous)
			indices.append(current)
			indices.append(previous + 1)
			indices.append(previous + 1)
			indices.append(current)
			indices.append(current + 1)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var shader := Shader.new()
	shader.code = BOSS_LIGHT_LEAK_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("beam_length", length)
	material.set_shader_parameter("falloff_distance", BOSS_LIGHT_FALLOFF_DISTANCE)
	var band := MeshInstance3D.new()
	band.name = "BossDestroyLightLeakBand"
	band.mesh = mesh
	band.material_override = material
	band.set_meta("boss_destroy_piece", "leak_band")
	band.set_meta("beam_length", length)
	band.set_meta("inner_width", 0.036 * width_scale * BOSS_CORE_VISUAL_SCALE)
	band.set_meta("outer_width", 0.250 * width_scale * BOSS_CORE_VISUAL_SCALE)
	return band


func _spawn_boss_destroy_effect(pos: Vector2, color: Color, source_node: Node3D = null) -> void:
	var root := Node3D.new()
	root.name = "BossDestroyEffect"
	root.position = _to_world(pos, 0.0)
	add_child(root)

	var anticipation: Node3D
	if source_node != null and is_instance_valid(source_node):
		anticipation = source_node.duplicate() as Node3D
		anticipation.position = Vector3(0.0, source_node.position.y, 0.0)
		anticipation.rotation = source_node.rotation
		anticipation.scale = source_node.scale
	else:
		anticipation = Node3D.new()
		anticipation.position.y = 0.30
		var fallback_model := _boss_core_caged_model(color)
		fallback_model.scale = Vector3.ONE * BOSS_CORE_VISUAL_SCALE
		anticipation.add_child(fallback_model)
	anticipation.name = "BossDestroyAnticipation"
	anticipation.set_meta("boss_destroy_piece", "anticipation")
	root.add_child(anticipation)
	for part_name in ["boss-core-wire-sphere", "boss-core-energy-shell"]:
		var compression_part := anticipation.find_child(part_name, true, false) as Node3D
		if compression_part == null:
			continue
		compression_part.set_meta("boss_destroy_compression_part", true)
		var compression_tween := create_tween()
		compression_tween.tween_interval(0.04)
		compression_tween.tween_property(compression_part, "scale", compression_part.scale * 0.42, BOSS_DESTROY_ANTICIPATION_TIME - 0.04).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var anticipation_hide := create_tween()
	anticipation_hide.tween_interval(BOSS_DESTROY_ANTICIPATION_TIME)
	anticipation_hide.tween_callback(anticipation.hide)

	var leak_stage := Node3D.new()
	leak_stage.name = "BossDestroyLightLeaks"
	leak_stage.set_meta("boss_destroy_piece", "leak_stage")
	leak_stage.position.y = 0.34
	root.add_child(leak_stage)
	var leak_count := randi_range(3, 4)
	var first_thick_leak := randi_range(0, leak_count - 1)
	var second_thick_leak := (first_thick_leak + randi_range(1, leak_count - 1)) % leak_count
	var leak_angles: Array[float] = []
	for i in range(leak_count):
		var candidate_angle := randf() * TAU
		var angle_is_clear := false
		while not angle_is_clear:
			angle_is_clear = true
			for existing_angle in leak_angles:
				if absf(angle_difference(candidate_angle, existing_angle)) < 0.55:
					angle_is_clear = false
					candidate_angle = randf() * TAU
					break
		leak_angles.append(candidate_angle)
	var leak_start_delay := 0.02
	for i in range(leak_count):
		if i > 0:
			leak_start_delay += randf_range(0.018, 0.026)
		var origin_angle := leak_angles[i]
		var leak_origin := Vector2.from_angle(origin_angle) * randf_range(0.18, 0.72) * BOSS_CORE_VISUAL_SCALE
		var dir := leak_origin.normalized().rotated(randf_range(-0.10, 0.10))
		var target_length := Vector2(FIELD_W, FIELD_H).length() * BOSS_LIGHT_LENGTH_MARGIN
		var leak := Node3D.new()
		leak.name = "BossDestroyLightLeak"
		leak.set_meta("boss_destroy_piece", "leak")
		leak.set_meta("start_delay", leak_start_delay)
		leak.set_meta("target_distance", target_length)
		leak.set_meta("origin", leak_origin)
		leak.set_meta("direction", dir)
		leak.set_meta("origin_angle", origin_angle)
		var is_thick := i == first_thick_leak or i == second_thick_leak
		var width_scale := randf_range(1.80, 2.35) if is_thick else randf_range(0.78, 1.12)
		leak.set_meta("is_thick", is_thick)
		leak.set_meta("width_scale", width_scale)
		var sweep_speed := randf_range(0.9, 2.4) * (-1.0 if randf() < 0.5 else 1.0)
		leak.set_meta("sweep_speed", sweep_speed)
		leak.position = _to_world(leak_origin, 0.0)
		leak.rotation.y = -dir.angle() + PI * 0.5
		leak_stage.add_child(leak)
		var extension_duration := randf_range(0.025, 0.045)
		leak.set_meta("extension_duration", extension_duration)
		var sweep_tween := create_tween()
		sweep_tween.tween_property(leak, "rotation:y", leak.rotation.y + sweep_speed * BOSS_DESTROY_ANTICIPATION_TIME, BOSS_DESTROY_ANTICIPATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		var band := _boss_light_leak_band(target_length, width_scale)
		leak.add_child(band)
		band.scale = Vector3(0.35, 1.0, 0.01)
		var band_tween := create_tween()
		band_tween.tween_interval(leak_start_delay)
		band_tween.tween_property(band, "scale", Vector3.ONE, extension_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var widening_duration := maxf(0.01, BOSS_DESTROY_ANTICIPATION_TIME - leak_start_delay - extension_duration)
		band_tween.tween_property(band, "scale", Vector3(1.28, 1.0, 1.0), widening_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var leak_hide := create_tween()
	leak_hide.tween_interval(BOSS_DESTROY_ANTICIPATION_TIME)
	leak_hide.tween_callback(leak_stage.hide)

	var plate_mat := _transparent_material(Color(color.r, color.g, color.b, 0.72), 1.65)
	var chunk_mat := _transparent_material(Color(color.lightened(0.16), 0.78), 1.42)
	var piece_count := 52
	for i in range(piece_count):
		var piece := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		var is_plate := i < 30
		if is_plate:
			piece.name = "BossDestroyPlate"
			piece.set_meta("boss_destroy_piece", "plate")
			var plate_size := randf_range(0.30, 0.68) * BOSS_CORE_VISUAL_SCALE
			mesh.size = Vector3(plate_size, 0.012 * BOSS_CORE_VISUAL_SCALE, plate_size * randf_range(0.70, 1.25))
			piece.material_override = plate_mat
		else:
			piece.name = "BossDestroyChunk"
			piece.set_meta("boss_destroy_piece", "chunk")
			mesh.size = Vector3(randf_range(0.10, 0.30), randf_range(0.045, 0.14), randf_range(0.22, 0.62)) * BOSS_CORE_VISUAL_SCALE
			piece.material_override = chunk_mat
		piece.mesh = mesh
		var angle := TAU * float(i) / float(piece_count) + randf_range(-0.18, 0.18)
		var dir := Vector2.from_angle(angle)
		piece.position = _to_world(dir * randf_range(0.04, 0.36) * BOSS_CORE_VISUAL_SCALE, randf_range(0.20, 0.62) * BOSS_CORE_VISUAL_SCALE)
		piece.rotation = Vector3(randf_range(-0.65, 0.65), angle + randf_range(-0.70, 0.70), randf_range(-0.55, 0.55))
		piece.visible = false
		root.add_child(piece)
		var long_range := i % 3 != 0
		var burst_delay := BOSS_DESTROY_SECOND_BURST_DELAY if long_range else BOSS_DESTROY_ANTICIPATION_TIME
		piece.set_meta("burst_delay", burst_delay)
		var target_distance := (randf_range(6.5, 10.5) if long_range else randf_range(3.2, 5.8)) * BOSS_CORE_VISUAL_SCALE
		piece.set_meta("target_distance", target_distance)
		var duration := randf_range(0.62, 0.94) if long_range else randf_range(0.46, 0.72)
		var target_height := randf_range(-0.12, 0.58)
		var tween := create_tween()
		tween.tween_interval(burst_delay)
		tween.tween_callback(piece.show)
		tween.tween_property(piece, "position", _to_world(dir * target_distance, target_height), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(piece, "rotation", piece.rotation + Vector3(randf_range(-5.2, 5.2), randf_range(4.0, 9.5), randf_range(-5.2, 5.2)), duration)
		tween.parallel().tween_property(piece, "scale", Vector3(randf_range(0.55, 1.25), randf_range(0.12, 0.40), randf_range(0.55, 1.25)), duration)
	var fade := create_tween()
	fade.tween_interval(BOSS_DESTROY_ANTICIPATION_TIME)
	fade.tween_property(plate_mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), 1.08)
	fade.parallel().tween_property(chunk_mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), 1.02)
	fade.tween_callback(root.queue_free)


func _spawn_player_burst(pos: Vector2) -> void:
	var burst := Node3D.new()
	burst.name = "PlayerCrashBurst"
	var plate_mat := _transparent_material(Color(palette.player_core.r, palette.player_core.g, palette.player_core.b, 0.68), 1.75)
	var chunk_mat := _transparent_material(Color(palette.player.r, palette.player.g, palette.player.b, 0.58), 1.25)
	for i in range(12):
		var shard := MeshInstance3D.new()
		shard.name = "PlayerCrashPlate"
		shard.set_meta("crash_piece", "plate")
		var mesh := BoxMesh.new()
		var size := 0.16 + float(i % 3) * 0.035
		mesh.size = Vector3(size, 0.010, size)
		shard.mesh = mesh
		shard.material_override = plate_mat
		var angle := TAU * float(i) / 12.0 + randf_range(-0.10, 0.10)
		var dir := Vector2.from_angle(angle)
		shard.position = _to_world(dir * randf_range(0.04, 0.10), 0.40)
		shard.rotation = Vector3(randf_range(-0.20, 0.20), angle + PI * 0.25, randf_range(-0.18, 0.18))
		burst.add_child(shard)
		var target_distance := randf_range(3.20, 5.10)
		shard.set_meta("target_distance", target_distance)
		var tween := create_tween()
		tween.parallel().tween_property(shard, "position", _to_world(dir * target_distance, randf_range(0.08, 0.34)), 0.52)
		tween.parallel().tween_property(shard, "rotation", shard.rotation + Vector3(randf_range(-3.0, 3.0), randf_range(3.2, 6.4), randf_range(-3.0, 3.0)), 0.52)
		tween.parallel().tween_property(shard, "scale", Vector3(1.85, 0.16, 1.85), 0.52)
	for i in range(8):
		var chunk := MeshInstance3D.new()
		chunk.name = "PlayerCrashChunk"
		chunk.set_meta("crash_piece", "chunk")
		var mesh := BoxMesh.new()
		mesh.size = Vector3(randf_range(0.055, 0.090), randf_range(0.035, 0.060), randf_range(0.12, 0.22))
		chunk.mesh = mesh
		chunk.material_override = chunk_mat
		var angle := TAU * (float(i) + 0.5) / 8.0 + randf_range(-0.16, 0.16)
		var dir := Vector2.from_angle(angle)
		chunk.position = _to_world(dir * randf_range(0.02, 0.08), 0.43)
		chunk.rotation = Vector3(randf() * TAU, angle, randf() * TAU)
		burst.add_child(chunk)
		var target_distance := randf_range(2.70, 4.40)
		chunk.set_meta("target_distance", target_distance)
		var tween := create_tween()
		tween.parallel().tween_property(chunk, "position", _to_world(dir * target_distance, randf_range(0.12, 0.42)), 0.50)
		tween.parallel().tween_property(chunk, "rotation", chunk.rotation + Vector3(randf_range(-4.0, 4.0), randf_range(4.0, 7.2), randf_range(-4.0, 4.0)), 0.50)
		tween.parallel().tween_property(chunk, "scale", Vector3(0.32, 0.32, 0.32), 0.50)
	burst.position = _to_world(pos, 0.0)
	add_child(burst)
	var fade := create_tween()
	fade.parallel().tween_property(plate_mat, "albedo_color", Color(palette.player_core.r, palette.player_core.g, palette.player_core.b, 0.0), 0.52)
	fade.parallel().tween_property(chunk_mat, "albedo_color", Color(palette.player.r, palette.player.g, palette.player.b, 0.0), 0.50)
	fade.tween_callback(burst.queue_free)


func _spawn_player_extend_effect(pos: Vector2) -> void:
	var effect := Node3D.new()
	effect.name = "PlayerExtendEffect"
	effect.position = _to_world(pos, PLAYER_EXTEND_VISUAL_HEIGHT)
	effect.rotation.y = player.rotation.y
	effect.set_meta("effect_type", "player_extend")
	add_child(effect)

	var player_core_color: Color = palette.player_core
	var wire_color: Color = player_core_color.lerp(Color(0.76, 1.0, 0.78), 0.42)
	var wire_material := _extend_effect_material(Color(wire_color.r, wire_color.g, wire_color.b, 0.72), 2.10)
	var wire_echo := Node3D.new()
	wire_echo.name = "PlayerExtendWireEcho"
	wire_echo.set_meta("extend_piece", "wire_echo")
	wire_echo.position.y = 0.04
	wire_echo.rotation = player.visual_model.rotation
	effect.add_child(wire_echo)
	_clone_player_wire_edges(player.visual_model, wire_echo, wire_material)

	var plate_material := _extend_effect_material(Color(0.72, 1.0, 0.80, 0.28), 0.90)
	for i in range(8):
		var plate := MeshInstance3D.new()
		plate.name = "PlayerExtendPlate"
		plate.set_meta("extend_piece", "plate")
		var plate_mesh := BoxMesh.new()
		var plate_size := 0.15 + float(i % 3) * 0.030
		plate_mesh.size = Vector3(plate_size, 0.006, plate_size)
		plate.mesh = plate_mesh
		plate.material_override = plate_material
		var angle := TAU * float(i) / 8.0 + PI * 0.125
		var direction := Vector2.from_angle(angle)
		plate.position = _to_world(direction * 0.22, 0.10)
		plate.rotation.y = angle + PI * 0.25
		effect.add_child(plate)
		var plate_tween := create_tween()
		plate_tween.parallel().tween_property(plate, "position", _to_world(direction * 1.25, 0.06), 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		plate_tween.parallel().tween_property(plate, "scale", Vector3.ONE * 1.24, 0.62)

	var core_material := _extend_effect_material(Color(1.0, 1.0, 0.82, 0.92), 3.05)
	var core_flash := MeshInstance3D.new()
	core_flash.name = "PlayerExtendCoreFlash"
	core_flash.set_meta("extend_piece", "core_flash")
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.10
	core_mesh.height = 0.20
	core_mesh.radial_segments = 8
	core_mesh.rings = 4
	core_flash.mesh = core_mesh
	core_flash.material_override = core_material
	core_flash.position = Vector3(0.0, 0.18, -0.08)
	core_flash.scale = Vector3.ONE * 0.50
	effect.add_child(core_flash)

	var motion := create_tween()
	motion.parallel().tween_property(wire_echo, "scale", Vector3.ONE * 2.15, 0.64).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion.parallel().tween_property(wire_echo, "rotation:y", wire_echo.rotation.y + 0.24, 0.64)
	motion.parallel().tween_property(core_flash, "scale", Vector3.ONE * 1.75, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var fade := create_tween()
	fade.tween_interval(0.10)
	fade.parallel().tween_property(wire_material, "albedo_color", Color(wire_color.r, wire_color.g, wire_color.b, 0.0), 0.58)
	fade.parallel().tween_property(plate_material, "albedo_color", Color(0.72, 1.0, 0.80, 0.0), 0.58)
	fade.parallel().tween_property(core_material, "albedo_color", Color(1.0, 1.0, 0.82, 0.0), 0.32)
	fade.tween_callback(effect.queue_free)


func _extend_effect_material(color: Color, emission: float) -> StandardMaterial3D:
	var material := _transparent_material(color, emission)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.render_priority = PLAYER_EXTEND_RENDER_PRIORITY
	return material


func _clone_player_wire_edges(source: Node, target: Node3D, material: Material) -> void:
	for source_child in source.get_children():
		var source_3d := source_child as Node3D
		if source_3d == null:
			continue
		var source_mesh := source_child as MeshInstance3D
		if source_mesh != null:
			if source_mesh.mesh is BoxMesh:
				var edge := MeshInstance3D.new()
				edge.name = "PlayerExtendWireEdge"
				edge.set_meta("extend_piece", "wire_edge")
				edge.mesh = source_mesh.mesh
				edge.transform = source_mesh.transform
				edge.material_override = material
				edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				target.add_child(edge)
			continue
		var branch := Node3D.new()
		branch.name = "%sExtendClone" % source_child.name
		branch.transform = source_3d.transform
		target.add_child(branch)
		_clone_player_wire_edges(source_child, branch, material)


func _update_player_backfire(delta: float) -> void:
	backfire_timer -= delta
	if backfire_timer > 0.0:
		return
	backfire_timer = 5.0 / 60.0
	_spawn_player_backfire(player.pos, player.angle)


func _spawn_player_backfire(pos: Vector2, angle: float) -> void:
	var flare := Node3D.new()
	flare.name = "PlayerBackfire"
	var mat := _transparent_material(Color(1.0, 0.84, 0.92, 0.18), 0.46)
	var forward := Vector2.from_angle(angle)
	var side := Vector2.from_angle(angle + PI * 0.5)
	var curve_sign := -1.0 if randf() < 0.5 else 1.0
	for i in range(3):
		var plate := MeshInstance3D.new()
		plate.name = "BackfirePlate"
		var mesh := BoxMesh.new()
		var t := float(i) / 2.0
		var size := 0.11 + pow(t, 1.6) * 0.20
		mesh.size = Vector3(size, 0.008, size)
		plate.mesh = mesh
		var lane := curve_sign * pow(t, 1.7) * 0.14
		var depth := 0.02 + pow(t, 1.35) * 0.66
		var local := side * lane - forward * depth
		plate.position = Vector3(local.x, 0.0, local.y)
		plate.rotation.y = angle + PI * 0.25
		plate.material_override = mat
		flare.add_child(plate)
	flare.position = _to_world(pos - forward * 0.16, 0.22)
	flare.scale = Vector3.ONE * 0.76
	add_child(flare)
	var drift := -forward * 2.15
	var tween := create_tween()
	tween.parallel().tween_property(flare, "position", _to_world(pos + drift, 0.17), 0.78)
	tween.parallel().tween_property(flare, "scale", Vector3(2.05, 0.18, 2.05), 0.78)
	tween.parallel().tween_property(mat, "albedo_color", Color(1.0, 0.84, 0.92, 0.0), 0.78)
	tween.tween_callback(flare.queue_free)


func _spawn_player_respawn_effect(pos: Vector2) -> void:
	var respawn := Node3D.new()
	respawn.name = "PlayerRespawnSquares"
	var mat := _transparent_material(Color(palette.player.r, palette.player.g, palette.player.b, 0.24), 0.76)
	for i in range(4):
		var plate := MeshInstance3D.new()
		plate.name = "PlayerRespawnPlate"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.34, 0.008, 0.34)
		plate.mesh = mesh
		plate.material_override = mat
		var angle := TAU * float(i) / 4.0 + PI * 0.25
		var dir := Vector2.from_angle(angle)
		plate.position = _to_world(dir * 0.95, 0.36)
		plate.rotation.y = angle
		respawn.add_child(plate)
		var tween := create_tween()
		tween.parallel().tween_property(plate, "position", _to_world(dir * 0.18, 0.34), 0.46)
		tween.parallel().tween_property(plate, "scale", Vector3(0.42, 0.16, 0.42), 0.46)
	respawn.position = _to_world(pos, 0.0)
	add_child(respawn)
	var fade := create_tween()
	fade.parallel().tween_property(mat, "albedo_color", Color(palette.player.r, palette.player.g, palette.player.b, 0.0), 0.46)
	fade.tween_callback(respawn.queue_free)


func _effect_line_mesh(a: Vector2, b: Vector2, width: float, material: Material) -> MeshInstance3D:
	var mid := (a + b) * 0.5
	var dir := b - a
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, maxf(0.01, dir.length()))
	line.mesh = mesh
	line.position = Vector3(mid.x, 0.0, mid.y)
	line.rotation.y = -dir.angle() + PI * 0.5
	line.material_override = material
	return line


func _update_player_spawn_effect(delta: float) -> void:
	player_spawn_effect_timer = maxf(0.0, player_spawn_effect_timer - delta)
	var age := SPAWN_EFFECT_TIME - player_spawn_effect_timer
	_apply_spawn_effect(player, age, 4.0, 0.50)


func _apply_spawn_effect(node: Node3D, age: float, start_scale: float, start_alpha: float) -> void:
	var t := clampf(age / SPAWN_EFFECT_TIME, 0.0, 1.0)
	node.scale = Vector3.ONE * lerpf(start_scale, 1.0, t)
	_set_node_alpha(node, lerpf(start_alpha, 1.0, t))


func _set_node_alpha(node: Node, alpha: float) -> void:
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null:
		var mat := mesh_instance.material_override as StandardMaterial3D
		if mat != null:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			var color := mat.albedo_color
			color.a = alpha
			mat.albedo_color = color
	for child in node.get_children():
		_set_node_alpha(child, alpha)


func _create_model_shadow(source: Node3D, shadow_name: String, alpha: float) -> Node3D:
	var shadow := Node3D.new()
	shadow.name = shadow_name
	var shadow_material := _transparent_material(Color(0.0, 0.0, 0.0, alpha), 0.10)
	_clone_shadow_children(source, shadow, shadow_material)
	add_child(shadow)
	return shadow


func _create_enemy_plate_shadow(kind: String, shadow_name: String, alpha: float) -> MeshInstance3D:
	var shadow := MeshInstance3D.new()
	shadow.name = shadow_name
	shadow.set_meta("enemy_plate_shadow", true)
	shadow.mesh = _enemy_shadow_plate_mesh(kind)
	shadow.material_override = _enemy_shadow_material(alpha)
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shadow)
	return shadow


func _create_player_plate_shadow() -> MeshInstance3D:
	var shadow := MeshInstance3D.new()
	shadow.name = "PlayerShadow"
	shadow.set_meta("player_plate_shadow", true)
	shadow.mesh = _player_shadow_plate_mesh()
	shadow.material_override = _enemy_shadow_material(PLAYER_PLATE_SHADOW_ALPHA)
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shadow)
	return shadow


func _enemy_shadow_material(alpha: float) -> StandardMaterial3D:
	var color := SOFT_SHADOW_TINT
	color.a = alpha
	var mat := _transparent_material(color, 0.04)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	return mat


func _enemy_shadow_plate_mesh(kind: String) -> Mesh:
	var radius := EnemyUtil.zako_radius(kind)
	var shape := _enemy_shadow_shape(kind)
	if shape == "triangle":
		return _soft_flat_polygon_mesh([
			Vector2(0.0, -radius * 1.45),
			Vector2(-radius * 0.92, radius * 0.72),
			Vector2(radius * 0.92, radius * 0.72),
		])
	if shape == "diamond":
		return _soft_flat_polygon_mesh([
			Vector2(0.0, -radius * 1.08),
			Vector2(radius * 1.08, 0.0),
			Vector2(0.0, radius * 1.08),
			Vector2(-radius * 1.08, 0.0),
		])
	var points: Array[Vector2] = []
	var segments := 12
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle) * radius * 1.05, sin(angle) * radius * 0.82))
	return _soft_flat_polygon_mesh(points)


func _player_shadow_plate_mesh() -> Mesh:
	return _soft_flat_polygon_mesh([
		Vector2(0.0, -1.18),
		Vector2(0.72, -0.42),
		Vector2(0.64, 0.54),
		Vector2(0.0, 0.86),
		Vector2(-0.64, 0.54),
		Vector2(-0.72, -0.42),
	])


func _enemy_shadow_shape(kind: String) -> String:
	if kind in ["zako0", "zako3p", "zako5", "zako7", "zako7p"]:
		return "triangle"
	if kind in ["zako1", "zako4", "zakoM0", "zakoM1"]:
		return "diamond"
	return "round"


func _soft_flat_polygon_mesh(points: Array[Vector2]) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var feather := SOFT_SHADOW_FEATHER
	vertices.append(Vector3.ZERO)
	colors.append(Color(1.0, 1.0, 1.0, SOFT_SHADOW_CENTER_ALPHA))
	for point in points:
		vertices.append(Vector3(point.x, 0.0, point.y))
		colors.append(Color(1.0, 1.0, 1.0, SOFT_SHADOW_INNER_ALPHA))
	for point in points:
		vertices.append(Vector3(point.x * feather, 0.0, point.y * feather))
		colors.append(Color(1.0, 1.0, 1.0, 0.0))
	for i in range(points.size()):
		indices.append_array([0, i + 1, 1 + ((i + 1) % points.size())])
		var inner_a := i + 1
		var inner_b := 1 + ((i + 1) % points.size())
		var outer_a := points.size() + i + 1
		var outer_b := points.size() + 1 + ((i + 1) % points.size())
		indices.append_array([inner_a, outer_a, inner_b, inner_b, outer_a, outer_b])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _clone_shadow_children(source: Node, target: Node, shadow_material: StandardMaterial3D) -> void:
	for child in source.get_children():
		var child_3d := child as Node3D
		if child_3d == null:
			continue
		if bool(child_3d.get_meta("skip_model_shadow", false)):
			continue
		var clone: Node3D
		var child_mesh := child as MeshInstance3D
		if child_mesh != null:
			var mesh_clone := MeshInstance3D.new()
			mesh_clone.mesh = child_mesh.mesh
			mesh_clone.material_override = shadow_material
			mesh_clone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			clone = mesh_clone
		else:
			clone = Node3D.new()
		clone.name = "%sShadow" % child.name
		clone.transform = child_3d.transform
		clone.visible = child_3d.visible
		clone.set_meta("shadow_source_instance_id", child_3d.get_instance_id())
		target.add_child(clone)
		_clone_shadow_children(child, clone, shadow_material)


func _sync_model_shadow(shadow: Node3D) -> void:
	for clone_node in shadow.get_children():
		var clone := clone_node as Node3D
		if clone == null:
			continue
		var source_id := int(clone.get_meta("shadow_source_instance_id", 0))
		if source_id != 0:
			var source := instance_from_id(source_id) as Node3D
			if source != null and is_instance_valid(source):
				clone.transform = source.transform
				clone.visible = source.visible
		_sync_model_shadow(clone)


func _update_enemy_shadow(enemy: Dictionary) -> void:
	var shadow: Node3D = enemy.get("shadow", null)
	if shadow == null or not is_instance_valid(shadow):
		return
	if not bool(shadow.get_meta("enemy_plate_shadow", false)):
		_sync_model_shadow(shadow)
	shadow.transform = _tunnel_shadow_transform(enemy.pos, enemy.node.rotation.y, enemy.node.scale)


func _free_enemy_nodes(enemy: Dictionary) -> void:
	if is_instance_valid(enemy.node):
		enemy.node.queue_free()
	var connection_line: Node = enemy.get("connection_line", null)
	if connection_line != null and is_instance_valid(connection_line):
		connection_line.queue_free()
	var shadow: Node = enemy.get("shadow", null)
	if shadow != null and is_instance_valid(shadow):
		shadow.queue_free()


func _is_player_hit_by_circle(pos: Vector2, radius: float) -> bool:
	var axis := _player_hit_axis()
	return CollisionUtil.circle_overlaps_capsule(pos, radius, axis[0], axis[1], PlayerUtil.HIT_RADIUS)


func _is_player_hit_by_enemy(pos: Vector2, radius: float) -> bool:
	return _is_player_hit_by_circle(pos, radius)


func _player_hit_axis() -> Array[Vector2]:
	return player.hit_axis()


func _boss_core_enemy() -> Dictionary:
	for enemy in enemies:
		if enemy.kind == "boss_core" and enemy.life > 0:
			return enemy
	return {}


func _update_boss_gum_attack(delta: float, player_can_be_hit: bool) -> void:
	var core := _boss_core_enemy()
	if core.is_empty():
		return
	var core_exposed: bool = core.get("damageable", false)
	var desired_count := BossGumControllerUtil.count_for_mode(
		game_state.game_mode,
		game_state.active_arcade_boss_rank,
		game_state.arcade_rank
	)
	boss_gum_controller.set_desired_count(desired_count, core.pos, core_exposed)
	if boss_gum_controller.update_attack(
		delta,
		core.pos,
		core_exposed,
		player.pos,
		player_can_be_hit,
		_player_hit_axis(),
		bullet_manager.bullets,
		bullet_manager.shape_for
	):
		_kill_player()


func _triangle_mesh(width: float, length: float, color: Color) -> MeshInstance3D:
	var verts := PackedVector3Array([
		Vector3(0.0, 0.22, -length * 0.50),
		Vector3(-width * 0.50, 0.0, length * 0.45),
		Vector3(width * 0.50, 0.0, length * 0.45),
		Vector3(0.0, -0.10, length * 0.10),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	return _array_mesh(verts, indices, _material(color, color, 0.9))


func _zako0_dihedral_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "glider-zako0"
	var nose := Vector3(0.0, 0.08, -0.52)
	_add_zako0_wing(model, nose, Vector3(-0.53, 0.21, 0.31), Vector3(-0.10, 0.10, -0.05), color)
	_add_zako0_wing(model, nose, Vector3(0.53, 0.21, 0.31), Vector3(0.10, 0.10, -0.05), color)
	var body_points := PackedVector3Array([
		nose + Vector3(0.0, 0.01, -0.05),
		nose + Vector3(-0.09, 0.0, 0.15),
		nose + Vector3(0.0, 0.015, 0.25),
		nose + Vector3(0.09, 0.0, 0.15),
		nose + Vector3(0.0, 0.10, 0.12),
		nose + Vector3(0.0, -0.10, 0.12),
	])
	var body_indices := PackedInt32Array([
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	])
	model.add_child(_array_mesh(body_points, body_indices, VisualMaterialsUtil.flat_face(color.lightened(0.12), 0.38, 0.85)))
	var body_edges := [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [2, 4], [0, 5], [2, 5]]
	for edge in body_edges:
		model.add_child(_faint_glow_edge(body_points[edge[0]], body_points[edge[1]], color.lightened(0.14)))
	return model


func _add_zako0_wing(root: Node3D, nose: Vector3, wing_tip: Vector3, inner_tail: Vector3, color: Color) -> void:
	var points := PackedVector3Array([nose, wing_tip, inner_tail])
	root.add_child(_array_mesh(points, PackedInt32Array([0, 1, 2, 0, 2, 1]), VisualMaterialsUtil.flat_face(color, 0.32, 0.72)))
	for edge in [[0, 1], [1, 2], [2, 0]]:
		root.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.10)))


func _faint_glow_edge(a: Vector3, b: Vector3, color: Color) -> MeshInstance3D:
	return _faint_glow_edge_width(a, b, color, ZAKO_BASE_OUTLINE_WIDTH)


func _faint_glow_edge_width(a: Vector3, b: Vector3, color: Color, width: float, alpha := 0.26, emission := 1.15) -> MeshInstance3D:
	var direction := b - a
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = VisualMaterialsUtil.outline(color, alpha, emission)
	return edge


func _edge_mesh_with_material(a: Vector3, b: Vector3, width: float, material: Material) -> MeshInstance3D:
	var direction := b - a
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = material
	return edge


func _zako1_thin_wedge_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "drifter-zako1"
	var points := PackedVector3Array([
		Vector3(0.0, 0.0, -0.48),
		Vector3(-ZAKO1_CROSS_SECTION_RADIUS, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.48),
		Vector3(ZAKO1_CROSS_SECTION_RADIUS, 0.0, 0.0),
		Vector3(0.0, ZAKO1_CROSS_SECTION_RADIUS, -0.04),
		Vector3(0.0, -ZAKO1_CROSS_SECTION_RADIUS, 0.04),
	])
	var indices := PackedInt32Array([
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	])
	model.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.36, 0.74)))
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [1, 4], [2, 4], [3, 4], [0, 5], [1, 5], [2, 5], [3, 5]]:
		model.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.10)))
	return model


func _zako2_fan_blocks_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "fan-zako2"
	var centers := [
		Vector3(-0.27, 0.0, -0.27), Vector3(0.27, 0.0, -0.27),
		Vector3(0.27, 0.0, 0.27), Vector3(-0.27, 0.0, 0.27),
	]
	for index in centers.size():
		_add_zako2_fan_block(model, index, centers[index], color)
	var hub_points := PackedVector3Array([
		Vector3(0.0, 0.10, 0.0), Vector3(-0.10, 0.0, 0.0),
		Vector3(0.0, 0.0, -0.10), Vector3(0.10, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.10), Vector3(0.0, -0.10, 0.0),
	])
	var hub_indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1,
		5, 2, 1, 5, 3, 2, 5, 4, 3, 5, 1, 4,
	])
	model.add_child(_array_mesh(hub_points, hub_indices, VisualMaterialsUtil.flat_face(color.darkened(0.08), 0.48, 0.72)))
	for edge in [[1, 2], [2, 3], [3, 4], [4, 1]]:
		model.add_child(_faint_glow_edge(hub_points[edge[0]], hub_points[edge[1]], color))
	return model


func _zako2_fan_blocks_light_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "fan-zako2-light"
	var centers := [
		Vector3(-0.27, 0.0, -0.27), Vector3(0.27, 0.0, -0.27),
		Vector3(0.27, 0.0, 0.27), Vector3(-0.27, 0.0, 0.27),
	]
	var face_material := VisualMaterialsUtil.flat_face(color, 0.31, 0.74)
	var edge_material := VisualMaterialsUtil.outline(color.lightened(0.10), 0.27, 1.02)
	for index in centers.size():
		var center: Vector3 = centers[index]
		var blade := Node3D.new()
		blade.name = "zako2-blade-%d" % index
		blade.position = center
		blade.set_meta("blade_pitch", ZAKO2_BLADE_PITCH)
		model.add_child(blade)
		var points := _zako2_blade_points(center)
		blade.add_child(_array_mesh(
			PackedVector3Array([points[0], points[1], points[2], points[3]]),
			PackedInt32Array([0, 1, 2, 0, 2, 3]),
			face_material
		))
		blade.add_child(_shadowless_mesh(_combined_edges_mesh_with_material([
			[points[0], points[1]], [points[1], points[2]], [points[2], points[3]], [points[3], points[0]],
		], 0.010, edge_material)))
	var hub_points := PackedVector3Array([
		Vector3(0.0, 0.10, 0.0), Vector3(-0.10, 0.0, 0.0),
		Vector3(0.0, 0.0, -0.10), Vector3(0.10, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.10), Vector3(0.0, -0.10, 0.0),
	])
	var hub_indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1,
		5, 2, 1, 5, 3, 2, 5, 4, 3, 5, 1, 4,
	])
	model.add_child(_array_mesh(hub_points, hub_indices, VisualMaterialsUtil.flat_face(color.darkened(0.08), 0.44, 0.72)))
	model.add_child(_shadowless_mesh(_combined_edges_mesh_with_material([
		[hub_points[1], hub_points[2]], [hub_points[2], hub_points[3]],
		[hub_points[3], hub_points[4]], [hub_points[4], hub_points[1]],
	], 0.010, edge_material)))
	return model


func _zako3_split_pod_model(shell_color: Color, part_color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako3-split-pod"
	var radii := Vector3(0.40, 0.27, 0.62)
	var gap := 0.045
	for quadrant in range(4):
		_add_zako3_ellipsoid_shell(model, quadrant, radii, gap, shell_color)
	for index in range(4):
		var part := _zako3p_low_wedge_model(part_color)
		var part_angle := PI * 0.25 + float(index) * PI * 0.5
		part.position = Vector3(cos(part_angle) * 0.14, 0.045 if index % 2 == 0 else -0.035, sin(part_angle) * 0.22)
		part.rotation.y = -part_angle + PI * 0.5
		part.rotation.x = 0.24 if index % 2 == 0 else -0.20
		part.rotation.z = -0.18 if index < 2 else 0.18
		part.scale = Vector3.ONE * 0.97
		model.add_child(part)
	return model


func _zako3_split_pod_light_model(shell_color: Color, part_color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako3-split-pod-light"
	var radii := Vector3(0.40, 0.27, 0.62)
	var gap := 0.045
	for quadrant in range(4):
		_add_zako3_ellipsoid_shell_light(model, quadrant, radii, gap, shell_color)
	for index in range(4):
		var part := _zako3p_low_wedge_light_model(part_color)
		var part_angle := PI * 0.25 + float(index) * PI * 0.5
		part.position = Vector3(cos(part_angle) * 0.14, 0.045 if index % 2 == 0 else -0.035, sin(part_angle) * 0.22)
		part.rotation.y = -part_angle + PI * 0.5
		part.rotation.x = 0.24 if index % 2 == 0 else -0.20
		part.rotation.z = -0.18 if index < 2 else 0.18
		part.scale = Vector3.ONE * 0.97
		model.add_child(part)
	return model


func _add_zako3_ellipsoid_shell_light(root: Node3D, quadrant: int, radii: Vector3, gap: float, color: Color) -> void:
	var theta_steps := 3
	var phi_steps := 4
	var start_theta := -PI * 0.5 + float(quadrant) * PI * 0.5
	var mid_theta := start_theta + PI * 0.25
	var offset := Vector3(cos(mid_theta), 0.0, sin(mid_theta)) * gap
	var points := PackedVector3Array()
	for phi_index in range(phi_steps + 1):
		var phi := -PI * 0.5 + PI * float(phi_index) / float(phi_steps)
		for theta_index in range(theta_steps + 1):
			var theta := start_theta + PI * 0.5 * float(theta_index) / float(theta_steps)
			points.append(offset + Vector3(
				cos(phi) * cos(theta) * radii.x,
				sin(phi) * radii.y,
				cos(phi) * sin(theta) * radii.z
			))
	var indices := PackedInt32Array()
	for phi_index in range(phi_steps):
		for theta_index in range(theta_steps):
			var a: int = phi_index * (theta_steps + 1) + theta_index
			var b: int = a + 1
			var c: int = a + theta_steps + 1
			var d: int = c + 1
			indices.append_array([a, c, b, b, c, d])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.025 * float(quadrant % 2)), 0.16, 0.52)))
	var edge_material := VisualMaterialsUtil.outline(color.lightened(0.05), 0.20, 0.78)
	var edges := []
	for theta_index in [0, theta_steps]:
		for phi_index in range(phi_steps):
			var a: int = phi_index * (theta_steps + 1) + theta_index
			var b: int = (phi_index + 1) * (theta_steps + 1) + theta_index
			edges.append([points[a], points[b]])
	var equator_row := int(float(phi_steps) / 2.0)
	for theta_index in range(theta_steps):
		var a: int = equator_row * (theta_steps + 1) + theta_index
		edges.append([points[a], points[a + 1]])
	root.add_child(_shadowless_mesh(_combined_edges_mesh_with_material(edges, 0.009, edge_material)))


func _add_zako3_ellipsoid_shell(root: Node3D, quadrant: int, radii: Vector3, gap: float, color: Color) -> void:
	var theta_steps := 3
	var phi_steps := 4
	var start_theta := -PI * 0.5 + float(quadrant) * PI * 0.5
	var mid_theta := start_theta + PI * 0.25
	var offset := Vector3(cos(mid_theta), 0.0, sin(mid_theta)) * gap
	var points := PackedVector3Array()
	for phi_index in range(phi_steps + 1):
		var phi := -PI * 0.5 + PI * float(phi_index) / float(phi_steps)
		for theta_index in range(theta_steps + 1):
			var theta := start_theta + PI * 0.5 * float(theta_index) / float(theta_steps)
			points.append(offset + Vector3(
				cos(phi) * cos(theta) * radii.x,
				sin(phi) * radii.y,
				cos(phi) * sin(theta) * radii.z
			))
	var indices := PackedInt32Array()
	for phi_index in range(phi_steps):
		for theta_index in range(theta_steps):
			var a: int = phi_index * (theta_steps + 1) + theta_index
			var b: int = a + 1
			var c: int = a + theta_steps + 1
			var d: int = c + 1
			indices.append_array([a, c, b, b, c, d])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.035 * float(quadrant % 2)), 0.18, 0.56)))
	for theta_index in [0, theta_steps]:
		for phi_index in range(phi_steps):
			var a: int = phi_index * (theta_steps + 1) + theta_index
			var b: int = (phi_index + 1) * (theta_steps + 1) + theta_index
			root.add_child(_faint_glow_edge(points[a], points[b], color))
	var equator_row := int(float(phi_steps) / 2.0)
	for theta_index in range(theta_steps):
		var a: int = equator_row * (theta_steps + 1) + theta_index
		root.add_child(_faint_glow_edge(points[a], points[a + 1], color))


func _zako3p_low_wedge_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako3p-low-wedge"
	var points := PackedVector3Array([
		Vector3(0.0, 0.12, -0.20), Vector3(-0.13, 0.0, 0.16),
		Vector3(0.13, 0.0, 0.16), Vector3(0.0, -0.10, 0.08),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	model.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.32, 0.75)))
	for edge in [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]]:
		model.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color))
	return model


func _zako3p_low_wedge_light_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako3p-low-wedge"
	var points := PackedVector3Array([
		Vector3(0.0, 0.12, -0.20), Vector3(-0.13, 0.0, 0.16),
		Vector3(0.13, 0.0, 0.16), Vector3(0.0, -0.10, 0.08),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	model.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.30, 0.70)))
	model.add_child(_shadowless_mesh(_combined_edges_mesh_with_material([
		[points[0], points[1]], [points[1], points[2]], [points[2], points[0]],
		[points[0], points[3]], [points[1], points[3]], [points[2], points[3]],
	], 0.009, VisualMaterialsUtil.outline(color.lightened(0.08), 0.22, 0.86))))
	return model


func _zako4_diamond_battery_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako4-diamond-battery"
	model.rotation.y = PI * 0.25
	var extent := 0.96
	var height := 0.065
	var wall := 0.075
	var half := extent * 0.5
	for part in [
		[Vector3(0.0, 0.0, -half), Vector3(extent, height, wall)],
		[Vector3(0.0, 0.0, half), Vector3(extent, height, wall)],
		[Vector3(-half, 0.0, 0.0), Vector3(wall, height, extent)],
		[Vector3(half, 0.0, 0.0), Vector3(wall, height, extent)],
	]:
		_add_zako4_box_part(model, part[0], part[1], color)
	for index in range(4):
		var turret := Node3D.new()
		var turret_angle := float(index) * PI * 0.5
		turret.position = Vector3(sin(turret_angle) * half, height * 0.65 + 0.07, -cos(turret_angle) * half)
		turret.rotation.y = -turret_angle
		model.add_child(turret)
		_add_zako4_box_part(turret, Vector3.ZERO, Vector3(0.22, 0.10, 0.22), color.lightened(0.05))
		_add_zako4_box_part(turret, Vector3(0.0, 0.0, -0.16), Vector3(0.075, 0.07, 0.28), color.lightened(0.10))
		var muzzle := Marker3D.new()
		muzzle.name = "zako4-muzzle-%d" % index
		muzzle.position = Vector3(0.0, 0.0, -0.30)
		turret.add_child(muzzle)
	return model


func _zako4_diamond_battery_light_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako4-diamond-battery-light"
	model.rotation.y = PI * 0.25
	var extent := 0.96
	var height := 0.065
	var wall := 0.075
	var half := extent * 0.5
	var face_material := VisualMaterialsUtil.flat_face(color, 0.27, 0.62)
	var edge_material := VisualMaterialsUtil.outline(color.lightened(0.08), 0.24, 0.94)
	for part in [
		[Vector3(0.0, 0.0, -half), Vector3(extent, height, wall)],
		[Vector3(0.0, 0.0, half), Vector3(extent, height, wall)],
		[Vector3(-half, 0.0, 0.0), Vector3(wall, height, extent)],
		[Vector3(half, 0.0, 0.0), Vector3(wall, height, extent)],
	]:
		_add_light_box_part(model, part[0], part[1], face_material, edge_material)
	for index in range(4):
		var turret := Node3D.new()
		var turret_angle := float(index) * PI * 0.5
		turret.position = Vector3(sin(turret_angle) * half, height * 0.65 + 0.07, -cos(turret_angle) * half)
		turret.rotation.y = -turret_angle
		model.add_child(turret)
		var gun_material := VisualMaterialsUtil.flat_face(color.lightened(0.07), 0.30, 0.66)
		_add_light_box_part(turret, Vector3.ZERO, Vector3(0.22, 0.10, 0.22), gun_material, edge_material)
		_add_light_box_part(turret, Vector3(0.0, 0.0, -0.16), Vector3(0.075, 0.065, 0.28), gun_material, edge_material)
		var muzzle := Marker3D.new()
		muzzle.name = "zako4-muzzle-%d" % index
		muzzle.position = Vector3(0.0, 0.0, -0.30)
		turret.add_child(muzzle)
	return model


func _zako4_diamond_battery_marker_model() -> Node3D:
	var model := Node3D.new()
	model.name = "zako4-diamond-battery-light"
	model.rotation.y = PI * 0.25
	var extent := 0.96
	var height := 0.065
	var half := extent * 0.5
	for index in range(4):
		var turret := Node3D.new()
		var turret_angle := float(index) * PI * 0.5
		turret.position = Vector3(sin(turret_angle) * half, height * 0.65 + 0.07, -cos(turret_angle) * half)
		turret.rotation.y = -turret_angle
		model.add_child(turret)
		var muzzle := Marker3D.new()
		muzzle.name = "zako4-muzzle-%d" % index
		muzzle.position = Vector3(0.0, 0.0, -0.30)
		turret.add_child(muzzle)
	return model


func _add_light_box_part(root: Node3D, center: Vector3, size: Vector3, face_material: Material, edge_material: Material) -> void:
	var half := size * 0.5
	var points := PackedVector3Array([
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	])
	root.add_child(_array_mesh(points, PackedInt32Array([
		0, 1, 2, 0, 2, 3,
		0, 4, 5, 0, 5, 1,
		1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3,
		3, 7, 4, 3, 4, 0,
	]), face_material))
	root.add_child(_shadowless_mesh(_combined_edges_mesh_with_material([
		[points[0], points[1]], [points[1], points[2]], [points[2], points[3]], [points[3], points[0]],
		[points[0], points[4]], [points[1], points[5]], [points[2], points[6]], [points[3], points[7]],
	], 0.009, edge_material)))


func _shadowless_mesh(mesh: MeshInstance3D) -> MeshInstance3D:
	mesh.set_meta("skip_model_shadow", true)
	return mesh


func _combined_edges_mesh_with_material(edges: Array, width: float, material: Material) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var half_width := width * 0.5
	var local_points := [
		Vector3(-half_width, -half_width, -0.5), Vector3(half_width, -half_width, -0.5),
		Vector3(half_width, half_width, -0.5), Vector3(-half_width, half_width, -0.5),
		Vector3(-half_width, -half_width, 0.5), Vector3(half_width, -half_width, 0.5),
		Vector3(half_width, half_width, 0.5), Vector3(-half_width, half_width, 0.5),
	]
	var box_indices := [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	]
	for edge in edges:
		var a := edge[0] as Vector3
		var b := edge[1] as Vector3
		var direction := b - a
		if direction.length_squared() <= 0.000001:
			continue
		var base_index := vertices.size()
		var transform := Transform3D(Basis(Quaternion(Vector3.FORWARD, direction.normalized())), (a + b) * 0.5)
		for local_point in local_points:
			vertices.append(transform * Vector3(local_point.x, local_point.y, local_point.z * direction.length()))
		for index in box_indices:
			indices.append(base_index + int(index))
	var mesh_instance := MeshInstance3D.new()
	var mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	return mesh_instance


func _add_zako4_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color, outline_width := ZAKO4_OUTLINE_WIDTH, outline_alpha := 0.26, outline_emission := 1.15) -> void:
	var half := size * 0.5
	var points := PackedVector3Array([
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	])
	var indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.32, 0.70)))
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		root.add_child(_faint_glow_edge_width(points[edge[0]], points[edge[1]], color, outline_width, outline_alpha, outline_emission))


func _zako5_armored_ray_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako5-armored-ray"
	var wing_points := PackedVector3Array([
		Vector3(0.0, 0.11, -0.46), Vector3(-0.92, 0.045, -0.08),
		Vector3(-0.62, 0.020, 0.14), Vector3(0.0, 0.075, 0.22),
		Vector3(0.74, 0.032, 0.12), Vector3(0.96, 0.065, -0.01),
		Vector3(0.0, -0.08, 0.02),
	])
	_add_zako5_polyhedron(model, wing_points, color)
	for line in [
		[Vector3(-0.76, 0.075, -0.08), Vector3(-0.28, 0.12, 0.02)],
		[Vector3(-0.28, 0.12, 0.02), Vector3(0.0, 0.14, -0.34)],
		[Vector3(0.0, 0.14, -0.34), Vector3(0.34, 0.10, 0.02)],
		[Vector3(0.34, 0.10, 0.02), Vector3(0.78, 0.08, -0.01)],
	]:
		model.add_child(_faint_glow_edge(line[0], line[1], color.lightened(0.18)))
	var body_points := PackedVector3Array([
		Vector3(0.0, 0.20, -0.42), Vector3(-0.12, 0.065, -0.08),
		Vector3(-0.065, 0.025, 0.46), Vector3(0.0, 0.035, 1.28),
		Vector3(0.065, 0.025, 0.46), Vector3(0.12, 0.065, -0.08),
		Vector3(0.0, -0.08, 0.18),
	])
	_add_zako5_polyhedron(model, body_points, color.lightened(0.10))
	return model


func _add_zako5_polyhedron(root: Node3D, points: PackedVector3Array, color: Color) -> void:
	var indices := PackedInt32Array([
		0, 1, 6, 1, 2, 6, 2, 3, 6, 3, 4, 6, 4, 5, 6, 5, 0, 6,
		0, 5, 4, 0, 4, 3, 0, 3, 2, 0, 2, 1,
	])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.08), 0.28, 0.62)))
	for edge in [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0], [0, 6], [3, 6]]:
		root.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.18)))


func _zako_m1_ridged_crystal_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zakoM1-ridged-crystal"
	var half_length := 1.08
	var half_width := 0.58
	var half_height := 0.46
	var points := PackedVector3Array([Vector3(0.0, 0.0, -half_length), Vector3(0.0, 0.0, half_length)])
	for ring in range(2):
		var z := -half_length * 0.32 if ring == 0 else half_length * 0.28
		for index in range(6):
			var angle := float(index) * TAU / 6.0
			var roughness := 1.0 + 0.08 * sin(float(index * 5 + ring * 3))
			points.append(Vector3(cos(angle) * half_width * roughness, sin(angle) * half_height * roughness, z))
	var indices := PackedInt32Array()
	for index in range(6):
		var next := (index + 1) % 6
		indices.append_array([0, 2 + index, 2 + next])
		indices.append_array([1, 8 + next, 8 + index])
		indices.append_array([2 + index, 8 + index, 2 + next, 2 + next, 8 + index, 8 + next])
	model.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color.darkened(0.08), 0.34, 0.58)))
	for index in range(6):
		var next := (index + 1) % 6
		for edge in [[0, 2 + index], [1, 8 + index], [2 + index, 2 + next], [8 + index, 8 + next], [2 + index, 8 + index]]:
			model.add_child(_faint_glow_edge_width(points[edge[0]], points[edge[1]], color.lightened(0.22), ZAKOM1_OUTLINE_WIDTH, 0.27, 1.15))
	for index in [0, 2, 4]:
		model.add_child(_faint_glow_edge_width(points[2 + index], points[8 + ((index + 1) % 6)], color.lightened(0.30), ZAKOM1_RIDGE_WIDTH, 0.31, 1.22))
	return model


func _zako6_tilted_orbits_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako6-tilted-orbits"
	model.rotation = Vector3(0.24, 0.0, -0.20)
	_add_zako6_outlined_sphere(model, Vector3.ZERO, 0.38, color, 0.12, 0.42, Vector3.ZERO, ZAKO6_OUTER_OUTLINE_WIDTH)
	_add_zako6_outlined_sphere(model, Vector3(-0.10, 0.07, -0.04), 0.23, color.lightened(0.08), 0.34, 0.68, Vector3(0.20, 0.0, -0.09), 0.012)
	_add_zako6_outlined_sphere(model, Vector3(0.16, -0.07, 0.07), 0.16, color.lightened(0.14), 0.42, 0.82, Vector3(0.13, 0.0, -0.36), 0.010)
	return model


func _zako7p_mini_crystal_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako7p-mini-crystal"
	var points := PackedVector3Array([
		Vector3(0.0, 0.0, -0.28), Vector3(-0.14, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.28), Vector3(0.14, 0.0, 0.0),
		Vector3(0.0, 0.11, -0.04), Vector3(0.0, -0.11, 0.04),
	])
	var indices := PackedInt32Array([
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	])
	model.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.42, 0.72)))
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [1, 4], [2, 4], [3, 4], [0, 5], [2, 5]]:
		model.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.16)))
	return model


func _zako7p_mini_crystal_light_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako7p-mini-crystal-light"
	var points := PackedVector3Array([
		Vector3(0.0, 0.0, -0.28), Vector3(-0.14, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.28), Vector3(0.14, 0.0, 0.0),
		Vector3(0.0, 0.11, -0.04), Vector3(0.0, -0.11, 0.04),
	])
	var indices := PackedInt32Array([
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	])
	model.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.38, 0.70)))
	for edge in [[0, 2], [1, 3], [0, 4], [2, 5]]:
		model.add_child(_faint_glow_edge_width(points[edge[0]], points[edge[1]], color.lightened(0.16), 0.012, 0.34, 1.05))
	return model


func _zako7_deep_v_glider_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zako7-deep-v-glider"
	var nose := Vector3(0.0, 0.14, -0.58)
	_add_zako7_v_wing(model, nose, Vector3(-0.72, 0.08, 0.42), Vector3(-0.12, 0.10, -0.12), color)
	_add_zako7_v_wing(model, nose, Vector3(0.72, 0.08, 0.42), Vector3(0.12, 0.10, -0.12), color)
	var body_width := 0.09
	var body_length := 0.92
	var body := PackedVector3Array([
		Vector3(0.0, 0.22, -0.62), Vector3(-body_width, 0.06, -0.16),
		Vector3(-body_width * 0.48, 0.03, body_length * 0.52), Vector3(0.0, 0.05, body_length),
		Vector3(body_width * 0.48, 0.03, body_length * 0.52), Vector3(body_width, 0.06, -0.16),
		Vector3(0.0, -0.10, 0.14),
	])
	_add_zako7_polyhedron(model, body, color.lightened(0.10))
	return model


func _add_zako7_v_wing(root: Node3D, nose: Vector3, wing_tip: Vector3, inner_tip: Vector3, color: Color) -> void:
	var thickness := Vector3(0.0, 0.045, 0.0)
	var points := PackedVector3Array([nose + thickness, wing_tip + thickness, inner_tip + thickness, nose - thickness, wing_tip - thickness, inner_tip - thickness])
	var indices := PackedInt32Array([
		0, 1, 2, 3, 5, 4,
		0, 3, 1, 1, 3, 4,
		1, 4, 2, 2, 4, 5,
		2, 5, 0, 0, 5, 3,
	])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.30, 0.72)))
	for edge in [[0, 1], [1, 2], [2, 0], [3, 4], [4, 5], [5, 3], [0, 3], [1, 4], [2, 5]]:
		root.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color))


func _add_zako7_polyhedron(root: Node3D, points: PackedVector3Array, color: Color) -> void:
	var indices := PackedInt32Array([
		0, 1, 6, 1, 2, 6, 2, 3, 6, 3, 4, 6, 4, 5, 6, 5, 0, 6,
		0, 5, 4, 0, 4, 3, 0, 3, 2, 0, 2, 1,
	])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.38, 0.76)))
	for edge in [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0], [0, 6], [3, 6]]:
		root.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color))


func _add_zako6_outlined_sphere(root: Node3D, position: Vector3, radius: float, color: Color, alpha: float, emission: float, outline_rotation: Vector3, outline_width: float) -> void:
	var sphere := _small_sphere_mesh(radius, color, emission)
	sphere.position = position
	sphere.material_override = VisualMaterialsUtil.flat_face(color, alpha, emission)
	root.add_child(sphere)
	var outline := Node3D.new()
	outline.position = position
	outline.rotation = outline_rotation
	root.add_child(outline)
	outline.add_child(_smooth_ring_mesh(radius * 1.04, outline_width, color))


func _smooth_ring_mesh(radius: float, tube: float, color: Color) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = maxf(0.02, radius - tube)
	mesh.outer_radius = radius
	mesh.ring_segments = 6
	mesh.rings = 24
	ring.mesh = mesh
	ring.material_override = VisualMaterialsUtil.outline(color, 0.26, 1.15)
	return ring


func _subtle_glow_edge(a: Vector3, b: Vector3, color: Color, width: float) -> MeshInstance3D:
	var direction := b - a
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = VisualMaterialsUtil.outline(color, 0.22, 0.95)
	return edge


func _zako_m0_lattice_keep_model(color: Color) -> Node3D:
	var model := Node3D.new()
	model.name = "zakoM0-lattice-keep"
	var extent := 1.54
	var wall_height := 0.24
	var wall_width := 0.15
	var half := extent * 0.5
	var structural_parts := [
		[Vector3(0.0, 0.0, -half), Vector3(extent, wall_height, wall_width)],
		[Vector3(0.0, 0.0, half), Vector3(extent, wall_height, wall_width)],
		[Vector3(-half, 0.0, 0.0), Vector3(wall_width, wall_height, extent)],
		[Vector3(half, 0.0, 0.0), Vector3(wall_width, wall_height, extent)],
	]
	var lattice_half := 0.69
	var lower_y := 0.16
	var upper_y := 0.43
	for side_x in [-1.0, 1.0]:
		for side_z in [-1.0, 1.0]:
			structural_parts.append([Vector3(side_x * lattice_half, 0.30, side_z * lattice_half), Vector3(0.13, 0.44, 0.13)])
	_add_zako_m0_combined_structure(model, structural_parts, color)
	var brace_index := 0
	for diagonal in [-1.0, 1.0]:
		var primary_brace := _zako_m0_lattice_edge(Vector3(-lattice_half, lower_y, -lattice_half * diagonal), Vector3(lattice_half, upper_y, lattice_half * diagonal), 0.028, color.lightened(0.16), 50.0 / 255.0, 1.38)
		primary_brace.name = "zakoM0-lattice-brace-%d" % brace_index
		model.add_child(primary_brace)
		brace_index += 1
		var secondary_brace := _zako_m0_lattice_edge(Vector3(-lattice_half, upper_y, -lattice_half * diagonal), Vector3(lattice_half, lower_y, lattice_half * diagonal), 0.018, color.lightened(0.04), 50.0 / 255.0, 1.08)
		secondary_brace.name = "zakoM0-lattice-brace-%d" % brace_index
		model.add_child(secondary_brace)
		brace_index += 1
	_add_zako_m0_crystal_plate(model, 0, 1.08, 0.17, color, 0.18, 0.35)
	_add_zako_m0_crystal_plate(model, 1, 0.76, 0.25, color, 0.23, 0.46)
	_add_zako_m0_crystal_plate(model, 2, 0.44, 0.33, color, 0.30, 0.60)
	return model


func _add_zako_m0_combined_structure(root: Node3D, parts: Array, color: Color) -> void:
	var face_vertices := PackedVector3Array()
	var face_indices := PackedInt32Array()
	var edge_vertices := PackedVector3Array()
	var edge_indices := PackedInt32Array()
	for part in parts:
		var center := part[0] as Vector3
		var size := part[1] as Vector3
		_append_box_geometry(face_vertices, face_indices, center, size)
		for segment in _box_edge_segments(center, size):
			_append_segment_box_geometry(edge_vertices, edge_indices, segment[0] as Vector3, segment[1] as Vector3, ZAKO_BASE_OUTLINE_WIDTH)
	var faces := _array_mesh(face_vertices, face_indices, VisualMaterialsUtil.flat_face(color.lightened(0.02), 0.32, 0.75))
	faces.name = "zakoM0-lattice-faces"
	root.add_child(faces)
	var edges := _array_mesh(edge_vertices, edge_indices, VisualMaterialsUtil.outline(color.lightened(0.12), 0.26, 1.15))
	edges.name = "zakoM0-lattice-edges"
	root.add_child(edges)


func _append_box_geometry(vertices: PackedVector3Array, indices: PackedInt32Array, center: Vector3, size: Vector3) -> void:
	var half := size * 0.5
	_append_cuboid_geometry(vertices, indices, [
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	])


func _append_segment_box_geometry(vertices: PackedVector3Array, indices: PackedInt32Array, a: Vector3, b: Vector3, width: float) -> void:
	var direction := b - a
	var half := Vector3(width * 0.5, width * 0.5, direction.length() * 0.5)
	var basis := Basis(Quaternion(Vector3.FORWARD, direction.normalized()))
	var center := (a + b) * 0.5
	var local_points := [
		Vector3(-half.x, half.y, -half.z), Vector3(half.x, half.y, -half.z),
		Vector3(half.x, half.y, half.z), Vector3(-half.x, half.y, half.z),
		Vector3(-half.x, -half.y, -half.z), Vector3(half.x, -half.y, -half.z),
		Vector3(half.x, -half.y, half.z), Vector3(-half.x, -half.y, half.z),
	]
	var points: Array[Vector3] = []
	for point in local_points:
		points.append(center + basis * (point as Vector3))
	_append_cuboid_geometry(vertices, indices, points)


func _append_cuboid_geometry(vertices: PackedVector3Array, indices: PackedInt32Array, points: Array) -> void:
	var offset := vertices.size()
	for point in points:
		vertices.append(point as Vector3)
	for index in [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	]:
		indices.append(offset + index)


func _box_edge_segments(center: Vector3, size: Vector3) -> Array:
	var half := size * 0.5
	var points := [
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	]
	var segments := []
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6],
		[6, 7], [7, 4], [0, 4], [1, 5], [2, 6], [3, 7],
	]:
		segments.append([points[edge[0]], points[edge[1]]])
	return segments


func _zako_m0_lattice_edge(a: Vector3, b: Vector3, width: float, color: Color, alpha: float, emission: float) -> MeshInstance3D:
	var direction := b - a
	var edge := MeshInstance3D.new()
	edge.name = "zakoM0-lattice-brace"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = VisualMaterialsUtil.outline(color, alpha, emission)
	return edge


func _add_zako_m0_crystal_plate(root: Node3D, index: int, extent: float, height: float, color: Color, alpha: float, emission: float) -> void:
	var half := extent * 0.5
	var plate := _array_mesh(PackedVector3Array([
		Vector3(-half, height, -half), Vector3(half, height, -half),
		Vector3(half, height, half), Vector3(-half, height, half),
	]), PackedInt32Array([0, 1, 2, 0, 2, 3]), VisualMaterialsUtil.flat_face(color.lightened(0.03), alpha, emission))
	plate.name = "zakoM0-crystal-plate-%d" % index
	root.add_child(plate)


func _add_zako_m0_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color) -> void:
	var half := size * 0.5
	var points := PackedVector3Array([
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	])
	var indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.32, 0.75)))
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		root.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color.lightened(0.10)))


func _add_zako2_fan_block(root: Node3D, index: int, center: Vector3, color: Color) -> void:
	var block := Node3D.new()
	block.name = "zako2-blade-%d" % index
	block.position = center
	block.set_meta("blade_pitch", ZAKO2_BLADE_PITCH)
	root.add_child(block)
	var points := _zako2_blade_points(center)
	var indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	])
	block.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.32, 0.75)))
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		block.add_child(_faint_glow_edge(points[edge[0]], points[edge[1]], color))


func _zako2_blade_points(center: Vector3) -> PackedVector3Array:
	var half_size := 0.21
	var half_height := 0.01
	var radial := Vector2(center.x, center.z).normalized()
	var tangent := Vector2(-radial.y, radial.x)
	var corners := [
		Vector2(-half_size, -half_size), Vector2(half_size, -half_size),
		Vector2(half_size, half_size), Vector2(-half_size, half_size),
	]
	var points := PackedVector3Array()
	for thickness_sign in [1.0, -1.0]:
		for corner in corners:
			var corner_2d := corner as Vector2
			var blade_height: float = corner_2d.dot(tangent) * tan(ZAKO2_BLADE_PITCH)
			points.append(Vector3(corner_2d.x, blade_height + half_height * thickness_sign, corner_2d.y))
	return points


func _diamond_mesh(length: float, width: float, color: Color) -> MeshInstance3D:
	var verts := PackedVector3Array([
		Vector3(0.0, 0.24, -length * 0.50),
		Vector3(-width * 0.50, 0.0, 0.0),
		Vector3(0.0, 0.24, length * 0.50),
		Vector3(width * 0.50, 0.0, 0.0),
		Vector3(0.0, -0.18, 0.0),
	])
	var indices := PackedInt32Array([0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0, 4, 0, 3, 1, 1, 3, 2])
	return _array_mesh(verts, indices, _material(color, color, 0.75))


func _mousetarget_reticle_model(color: Color) -> Node3D:
	var reticle := Node3D.new()
	reticle.name = "mousetarget-reticle-model"
	var marker_color := color.lightened(0.06)
	var cross_color := color.darkened(0.04)
	for line_name in ["left", "right", "top", "bottom"]:
		var cross_line := _line_mesh(Vector2.ZERO, Vector2.ZERO, 0.014, cross_color)
		cross_line.name = "mousetarget-crosshair-%s" % line_name
		reticle.add_child(cross_line)
	var corner_outer := 0.38
	var corner_width := 0.016
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			var corner := _mousetarget_corner_marker(sx, sy, corner_outer, corner_width, marker_color)
			reticle.add_child(corner)
	var diamond := _line_mesh(Vector2(-0.085, 0.0), Vector2(0.0, -0.085), 0.010, color.darkened(0.08))
	reticle.add_child(diamond)
	reticle.add_child(_line_mesh(Vector2(0.0, -0.085), Vector2(0.085, 0.0), 0.010, color.darkened(0.08)))
	reticle.add_child(_line_mesh(Vector2(0.085, 0.0), Vector2(0.0, 0.085), 0.010, color.darkened(0.08)))
	reticle.add_child(_line_mesh(Vector2(0.0, 0.085), Vector2(-0.085, 0.0), 0.010, color.darkened(0.08)))
	var sweep := Node3D.new()
	sweep.name = "mousetarget-visibility-sweep"
	var sweep_color := Color(1.0, 0.95, 0.52)
	sweep.add_child(_line_mesh(Vector2(-0.060, -0.45), Vector2(0.060, -0.45), 0.022, sweep_color))
	sweep.add_child(_line_mesh(Vector2(0.060, -0.45), Vector2(0.105, -0.37), 0.015, sweep_color))
	sweep.add_child(_line_mesh(Vector2(-0.060, -0.45), Vector2(-0.105, -0.37), 0.015, sweep_color))
	reticle.add_child(sweep)
	_apply_mousetarget_reticle_state(reticle, 0.0)
	return reticle


func _mousetarget_corner_marker(sx: float, sy: float, outer: float, width: float, color: Color) -> Node3D:
	var corner := Node3D.new()
	corner.name = "mousetarget-corner-marker"
	corner.set_meta("sx", sx)
	corner.set_meta("sy", sy)
	var leg := 0.15
	corner.add_child(_line_mesh(Vector2.ZERO, Vector2(-sx * leg, 0.0), width, color))
	corner.add_child(_line_mesh(Vector2.ZERO, Vector2(0.0, -sy * leg), width, color))
	corner.position = Vector3(sx * outer, 0.0, sy * outer)
	return corner


func _apply_mousetarget_reticle_state(reticle: Node3D, fire_blend: float) -> void:
	var blend := clampf(fire_blend, 0.0, 1.0)
	var corner_radius := lerpf(0.38, 0.22, blend)
	for marker in _mousetarget_corner_markers(reticle):
		var corner := marker as Node3D
		if corner == null:
			continue
		var sx := float(corner.get_meta("sx", 1.0))
		var sy := float(corner.get_meta("sy", 1.0))
		corner.position = Vector3(sx * corner_radius, 0.0, sy * corner_radius)
	var inner := lerpf(0.14, 0.18, blend)
	var outer := lerpf(0.36, 0.52, blend)
	var cross_width := lerpf(0.014, 0.017, blend)
	_set_named_line(reticle, "mousetarget-crosshair-left", Vector2(-outer, 0.0), Vector2(-inner, 0.0), cross_width)
	_set_named_line(reticle, "mousetarget-crosshair-right", Vector2(inner, 0.0), Vector2(outer, 0.0), cross_width)
	_set_named_line(reticle, "mousetarget-crosshair-top", Vector2(0.0, -outer), Vector2(0.0, -inner), cross_width)
	_set_named_line(reticle, "mousetarget-crosshair-bottom", Vector2(0.0, inner), Vector2(0.0, outer), cross_width)


func _set_named_line(root: Node, line_name: String, a: Vector2, b: Vector2, width: float) -> void:
	var line := root.find_child(line_name, true, false) as MeshInstance3D
	if line != null:
		_set_line_mesh(line, a, b, width)


func _mousetarget_corner_markers(root: Node) -> Array[Node3D]:
	var markers: Array[Node3D] = []
	var root_3d := root as Node3D
	if root_3d != null and root_3d.has_meta("sx") and root_3d.has_meta("sy"):
		markers.append(root_3d)
	for child in root.get_children():
		markers.append_array(_mousetarget_corner_markers(child))
	return markers


func _cross_mesh(length: float, width: float, color: Color) -> Node3D:
	var cross := Node3D.new()
	var horizontal := _line_mesh(Vector2(-length * 0.5, 0.0), Vector2(length * 0.5, 0.0), width, color)
	var vertical := _line_mesh(Vector2(0.0, -length * 0.5), Vector2(0.0, length * 0.5), width, color)
	horizontal.position.y = 0.18
	vertical.position.y = 0.18
	cross.add_child(horizontal)
	cross.add_child(vertical)
	return cross


func _small_sphere_mesh(radius: float, color: Color, energy: float) -> MeshInstance3D:
	var sphere_node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	sphere_node.mesh = mesh
	sphere_node.material_override = _material(color, color, energy)
	return sphere_node


func _ring_mesh(radius: float, tube: float, color: Color) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = maxf(0.02, radius - tube)
	mesh.outer_radius = radius
	mesh.ring_segments = 16
	ring.mesh = mesh
	ring.material_override = _material(color, color, 1.0)
	return ring


func _line_mesh(a: Vector2, b: Vector2, width: float, color: Color) -> MeshInstance3D:
	var mid := (a + b) * 0.5
	var dir := b - a
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, maxf(0.01, dir.length()))
	line.mesh = mesh
	line.position = _to_world(mid, 0.02)
	line.rotation.y = -dir.angle() + PI * 0.5
	line.material_override = _material(color, color, 0.35)
	return line


func _set_line_mesh(line: MeshInstance3D, a: Vector2, b: Vector2, width: float) -> void:
	var mid := (a + b) * 0.5
	var dir := b - a
	var mesh := line.mesh as BoxMesh
	if mesh != null:
		mesh.size = Vector3(width, width, maxf(0.01, dir.length()))
	line.position = _to_world(mid, 0.018)
	line.rotation.y = -dir.angle() + PI * 0.5


func _array_mesh(verts: PackedVector3Array, indices: PackedInt32Array, mat: Material) -> MeshInstance3D:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	return mi


func _material(albedo: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.42
	return mat


func _floor_material() -> StandardMaterial3D:
	return _material(Color(0.012, 0.024, 0.032), Color(0.0, 0.06, 0.07), 0.12)


func _background_light_energy(bg_color: Color) -> float:
	var luminance := bg_color.r * 0.2126 + bg_color.g * 0.7152 + bg_color.b * 0.0722
	if luminance < 0.014:
		return 0.62
	if luminance < 0.035:
		return 1.35
	return 2.2


func _update_background_light() -> void:
	if main_light == null:
		return
	var breath_phase := 0.5 + 0.5 * sin(tunnel_time * BACKGROUND_LIGHT_BREATH_SPEED * TAU)
	var dim_factor := lerpf(1.0 - BACKGROUND_LIGHT_BREATH_DEPTH, 1.0, breath_phase)
	main_light.light_energy = background_light_base_energy * dim_factor
	main_light.rotation_degrees = BACKGROUND_LIGHT_BASE_ROTATION + Vector3(
		sin(tunnel_time * 0.16) * 5.0,
		sin(tunnel_time * 0.23) * 10.0,
		cos(tunnel_time * 0.19) * 3.0
	)


func _transparent_material(albedo: Color, energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(albedo.r, albedo.g, albedo.b, 1.0)
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.65
	return mat


func _to_world(v: Vector2, height: float) -> Vector3:
	return Vector3(v.x, height, v.y)
