class_name Enemy
extends RefCounted

const DEATH_NONE := ""
const DEATH_SPAWN_ZAKO3_PARTS := "spawn_zako3_parts"
const DEATH_RELEASE_ZAKO7_CHAIN := "release_zako7_chain"
const ZAKO0_SPEED := 5.25
const ZAKO1_SPEED := 1.5
const ZAKO2_SPEED := 3.0
const ZAKO2_HOMING_SPEED := 0.3
const ZAKO2_VISUAL_SPIN_SPEED := deg_to_rad(10.0 * 60.0)
const ZAKO3_TUMBLE_SPEED_MIN := 0.32
const ZAKO3_TUMBLE_SPEED_MAX := 0.58
const ZAKO3P_SPEED := 3.0
const ZAKO4_SPEED := 1.5
const ZAKO5_SPEED := 5.25
const ZAKO6_SPEED := 6.0
const ZAKO7_SPEED := 3.0
const ZAKO7P_SPEED := 3.0
const ZAKOM1_SPEED := 3.0
const BOSS_TURRET_T1_SCORE := 800
const BOSS_TURRET_T2_SCORE := 200
const BOSS_TURRET_T3_SCORE := 1200

const DISPLAY_NAMES := {
	"zako0": "Crimson Glider",
	"zako1": "Amber Drifter",
	"zako2": "Verdant Fan",
	"zako3": "Split Pod",
	"zako3p": "Hatch Wedge",
	"zako4": "Diamond Battery",
	"zako5": "Armored Ray",
	"zako6": "Orbit Wisp",
	"zako7": "Viper Glider",
	"zako7p": "Chain Crystal",
	"zakoM0": "Lattice Keep",
	"zakoM1": "Ridged Comet",
	"boss_core": "Caged Core",
	"boss_turret_t1": "Rapid Rail",
	"boss_turret_t2": "Opposing Frame",
	"boss_turret_t3": "Burst Triad",
}


static func display_name(kind: String) -> String:
	return DISPLAY_NAMES.get(kind, kind)


static func create_zako(kind: String, node: Node3D, pos: Vector2, angle: float, color: Color, chain_id: int, gun0: Node3D = null, gun1: Node3D = null) -> Dictionary:
	var enemy := _base(kind, node, pos, angle, color, zako_life(kind), zako_radius(kind))
	enemy.drift_angle = angle + randf_range(-0.8, 0.8)
	enemy.rev = -1.0 if randf() < 0.5 else 1.0
	enemy.fire_offset = randf_range(0.0, 0.6)
	enemy.spin = randf_range(2.0, 5.5) * (-1.0 if randf() < 0.5 else 1.0)
	enemy.tumble_axis = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-0.65, 0.65),
		randf_range(-1.0, 1.0)
	).normalized()
	enemy.tumble_speed = randf_range(ZAKO3_TUMBLE_SPEED_MIN, ZAKO3_TUMBLE_SPEED_MAX) * (-1.0 if randf() < 0.5 else 1.0)
	if kind == "zako2":
		enemy.spin = ZAKO2_VISUAL_SPIN_SPEED * enemy.rev
	enemy.damageable = kind != "zako7p"
	enemy.gum_vulnerable = kind != "zako7p"
	enemy.blocks_shots = kind == "zako7p"
	enemy.chain_id = chain_id
	enemy.gun0 = gun0
	enemy.gun1 = gun1
	enemy.gun0_recoil = 0.0
	enemy.gun1_recoil = 0.0
	return enemy


static func create_boss_core(node: Node3D, pos: Vector2, color: Color, life: int, radius: float) -> Dictionary:
	var enemy := _base("boss_core", node, pos, 0.0, color, life, radius)
	enemy.score_base = 0
	enemy.damageable = false
	enemy.gum_vulnerable = false
	enemy.core_gun_angle = 0.0
	enemy.core_gun_fire_timer = 0.0
	enemy.core_burst_active = false
	enemy.core_burst_recoil = 0.0
	enemy.core_last_life = life
	enemy.core_damage_flash = 0.0
	enemy.core_damage_flash_cooldown = 0.0
	enemy.core_unlock_flash = 0.0
	enemy.core_just_unlocked = false
	return enemy


static func create_boss_turret(kind: String, node: Node3D, pos: Vector2, color: Color, life: int, radius: float, offset: Vector2) -> Dictionary:
	var enemy := _base(kind, node, pos, 0.0, color, life, radius)
	enemy.spin = 0.7
	enemy.offset = offset
	enemy.fire_offset = randf()
	enemy.rev = -1.0 if randf() < 0.5 else 1.0
	enemy.t_body_angle = offset.angle() if not offset.is_zero_approx() else randf() * TAU
	enemy.t_slow_gun_angle = randf() * TAU
	enemy.t_slow_gun_timer = 0.0
	enemy.t_slow_gun_recoil = 0.0
	enemy.t_fixed_gun_recoil = 0.0
	enemy.t_emitter_recoil = 0.0
	enemy.turret_last_life = life
	enemy.turret_damage_flash = 0.0
	enemy.turret_damage_flash_cooldown = 0.0
	enemy.damageable = false
	enemy.score_base = boss_turret_score(kind)
	return enemy


static func boss_turret_score(kind: String) -> int:
	if kind == "boss_turret_t1":
		return BOSS_TURRET_T1_SCORE
	if kind == "boss_turret_t3":
		return BOSS_TURRET_T3_SCORE
	return BOSS_TURRET_T2_SCORE


static func zako_life(kind: String) -> int:
	if kind == "zakoM0" or kind == "zakoM1":
		return 28
	if kind == "zako1":
		return 2
	return 1


static func zako_radius(kind: String) -> float:
	if kind == "zako1":
		return 0.41
	if kind == "zako2":
		return 0.52
	if kind == "zako3":
		return 0.56
	if kind == "zako3p":
		return 0.28
	if kind == "zako4":
		return 0.52
	if kind == "zako5":
		return 0.36
	if kind == "zako6":
		return 0.24
	if kind == "zako7":
		return 0.36
	if kind == "zako7p":
		return 0.28
	if kind == "zakoM0":
		return 1.08
	if kind == "zakoM1":
		return 0.86
	return 0.36


static func zako_score(kind: String) -> int:
	if kind == "zako0":
		return 20
	if kind == "zako1":
		return 5
	if kind == "zako2":
		return 10
	if kind == "zako3":
		return 5
	if kind == "zako3p":
		return 5
	if kind == "zako4":
		return 30
	if kind == "zako5":
		return 20
	if kind == "zako6":
		return 10
	if kind == "zako7":
		return 20
	if kind == "zakoM0":
		return 100
	if kind == "zakoM1":
		return 120
	return 0


static func death_action(enemy: Dictionary) -> String:
	if enemy.kind == "zako3":
		return DEATH_SPAWN_ZAKO3_PARTS
	if enemy.kind == "zako7":
		return DEATH_RELEASE_ZAKO7_CHAIN
	return DEATH_NONE


static func is_boss(enemy: Dictionary) -> bool:
	return enemy.kind.begins_with("boss_")


static func release_chain_part(enemy: Dictionary) -> void:
	enemy.chain_released = true
	enemy.damageable = true
	enemy.gum_vulnerable = true
	enemy.blocks_shots = false
	enemy.segment = 0


static func _base(kind: String, node: Node3D, pos: Vector2, angle: float, color: Color, life: int, radius: float) -> Dictionary:
	return {
		"node": node,
		"kind": kind,
		"display_name": display_name(kind),
		"pos": pos,
		"angle": angle,
		"drift_angle": angle,
		"rev": 1.0,
		"fire_offset": 0.0,
		"spin": 0.0,
		"tumble_axis": Vector3.RIGHT,
		"tumble_speed": 0.0,
		"life": life,
		"radius": radius,
		"score_base": zako_score(kind),
		"age": 0.0,
		"color": color,
		"damageable": true,
		"gum_vulnerable": true,
		"blocks_shots": false,
		"chain_released": false,
		"chain_id": -1,
		"segment": 0,
		"gun0": null,
		"gun1": null,
	}
