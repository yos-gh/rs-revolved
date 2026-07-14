extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	main.set_process(false)

	assert(not main.game_over_layer.visible)
	assert(not main.arcade_clear_layer.visible)
	var game_over_label := main.game_over_layer.find_child("GameOverLabel", true, false) as TextureRect
	var clear_label := main.arcade_clear_layer.find_child("ArcadeClearLabel", true, false) as TextureRect
	assert(game_over_label != null)
	assert(clear_label != null)
	assert((game_over_label.texture as AtlasTexture).region == Rect2(0, 224, 1360, 56))
	assert((clear_label.texture as AtlasTexture).region == Rect2(0, 280, 1360, 56))
	assert((game_over_label.texture as AtlasTexture).filter_clip)
	assert((clear_label.texture as AtlasTexture).filter_clip)

	main._start_arcade()
	main.bgm.sync("arcade", 0, 1)
	assert(main.bgm.current_track == 1)
	main.bullet_manager.spawn_hostile_bullet(Vector2.ZERO, 0.0, 1.0, true, "circle")
	var bullets_before_game_over := main.bullet_manager.count()
	main.game_state.player_lives = 0
	main.player.invuln_timer = 0.0
	main._kill_player()
	assert(main.game_state.player_lives == -1)
	assert(not main.player.alive)
	assert(main.bullet_manager.count() == bullets_before_game_over)
	main._show_game_over()
	assert(main.game_state.game_over)
	assert(main.bgm.current_track == 0)
	assert(not main.bgm.player.playing)
	assert(main.game_over_layer.visible)
	assert(main.hud.visible)
	assert(not main.arcade_clear_layer.visible)
	assert(main.bullet_manager.count() == bullets_before_game_over)
	main._spawn_enemy("zako4", Vector2(2.0, 1.0))
	main._update_enemy_visual_batches()
	var spawned_zako4: Dictionary = main.enemies.back()
	var zako4_pos_before: Vector2 = spawned_zako4.pos
	var zako4_batch := main.enemy_visual_batches["zako4"] as Dictionary
	var zako4_visual_entries := zako4_batch.visual_entries as Array
	var zako4_multimesh := zako4_visual_entries[0].multimesh as MultiMesh
	var spawn_frames_before := main.spawner.generator_counter
	for i in range(10):
		main._process(1.0 / 60.0)
	assert(main.spawner.generator_counter > spawn_frames_before)
	assert((spawned_zako4.pos as Vector2) != zako4_pos_before)
	assert(zako4_multimesh.instance_count > 0)
	assert(main.bgm.current_track == 0)
	assert(not main.bgm.player.playing)

	main._return_to_title()
	assert(not main.game_state.game_over)
	assert(not main.game_over_layer.visible)

	main._start_arcade()
	main.bullet_manager.spawn_player_shot(Vector2.ZERO, 0.0)
	main.bullet_manager.spawn_hostile_bullet(Vector2.ONE, 0.0, 1.0, true, "circle")
	main._clear_hostile_bullets()
	assert(main.bullet_manager.count() == 1)
	assert(not main.bullet_manager.bullets[0].hostile)
	main.game_state.active_arcade_boss_rank = 15
	main.game_state.boss_mode = true
	main.bgm.sync("arcade", 0, 3)
	assert(main.bgm.current_track == 3)
	main.spawner.spawn_queue.append({"kind": "zakoM1", "pos": Vector2.ZERO})
	main._end_boss_mode()
	assert(main.spawner.spawn_queue.is_empty())
	main.spawner.spawn_queue.append({"kind": "zakoM1", "pos": Vector2.ZERO})
	main._update_spawning(1.0 / 60.0)
	main._spawn_enemy("zakoM1", Vector2.ZERO)
	assert(main.game_state.arcade_cleared)
	assert(main.bgm.current_track == 0)
	assert(not main.bgm.player.playing)
	assert(main.arcade_clear_layer.visible)
	assert(main.hud.visible)
	assert(not main.game_over_layer.visible)
	assert(main.player.visible)
	assert(main.gum_controller.visible)
	assert(not main.aim_reticle.visible)
	assert(main.player_shadow == null)
	assert(main.bullet_manager.count() == 1)
	assert(main.enemies.is_empty())
	var clear_spawn_frames := main.spawner.generator_counter
	var shot_pos_before: Vector2 = main.bullet_manager.bullets[0].pos
	main._process(1.0 / 60.0)
	assert(main.spawner.generator_counter == clear_spawn_frames)
	assert((main.bullet_manager.bullets[0].pos as Vector2) != shot_pos_before)
	assert(not main.aim_reticle.visible)
	assert(main.bgm.current_track == 0)
	assert(not main.bgm.player.playing)

	main.queue_free()
	await process_frame
	await process_frame
	print("result screen verification passed")
	quit()
