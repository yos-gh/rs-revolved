extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")
const BulletManagerUtil := preload("res://scripts/game/bullet_manager.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.set_process(false)

	var adopted_models := {
		"0:2": "glider-zako0",
		"1:0": "drifter-zako1",
		"2:2": "fan-zako2",
		"3:0": "bullet0-rugby-spindle",
		"4:2": "zakoM0-lattice-keep",
		"5:2": "bullet1-low-prism",
		"6:2": "zako3-split-pod",
		"7:1": "zako3p-low-wedge",
		"8:1": "zako4-diamond-battery",
		"9:1": "bullet2-low-prism",
		"10:2": "zako5-armored-ray",
		"11:2": "zakoM1-ridged-crystal",
		"12:2": "zako6-tilted-orbits",
		"13:1": "zako7-deep-v-glider",
		"14:0": "zako7p-mini-crystal",
		"15:2": "bullet3-low-rail",
		"16:1": "boss-b1-additive-rect",
		"17:1": "boss-core-caged",
		"19:0": "player-shot-wireframe",
		"20:0": "mousetarget-reticle-model",
		"21:0": "GumOrb",
		"22:2": "player-armored-pods",
		"23:0": "boss-connection-ribbon-trial-0",
		"23:1": "boss-connection-ribbon-trial-1",
		"23:2": "boss-connection-ribbon-trial-2",
	}
	for key in adopted_models:
		var coordinates := (key as String).split(":")
		var category := int(coordinates[0])
		var candidate := int(coordinates[1])
		var candidate_root := main.model_gallery.category_roots[category].get_child(candidate) as Node3D
		assert(candidate_root.find_child(adopted_models[key], true, false) != null, "Missing shared model %s at %s" % [adopted_models[key], key])

	assert(EnemyUtil.display_name("zako2") == "Verdant Fan")
	assert(EnemyUtil.display_name("zakoM0") == "Lattice Keep")
	assert(BulletManagerUtil.DISPLAY_NAMES.bullet0 == "Rugby Spindle")
	assert(BulletManagerUtil.DISPLAY_NAMES.boss_b1 == "Piercing Light")

	main.queue_free()
	await process_frame
	await process_frame
	print("shared model gallery verification passed")
	quit()
