class_name VisualMotion
extends RefCounted


static func local_motion(root: Node3D, world_motion: Vector2) -> Vector2:
	if world_motion.is_zero_approx():
		return Vector2.ZERO
	var local_3d := root.basis.orthonormalized().inverse() * Vector3(world_motion.x, 0.0, world_motion.y)
	return Vector2(local_3d.x, local_3d.z).limit_length(1.0)


static func update_bank_pitch(
	pivot: Node3D,
	local_direction: Vector2,
	turn_input: float,
	delta: float,
	max_bank: float,
	max_pitch: float,
	response: float
) -> void:
	if pivot == null:
		return
	var target_bank := clampf(
		-local_direction.x * max_bank - clampf(turn_input, -1.0, 1.0) * max_bank,
		-max_bank,
		max_bank
	)
	var target_pitch := clampf(local_direction.y * max_pitch, -max_pitch, max_pitch)
	var blend := 1.0 - exp(-maxf(0.0, response) * maxf(0.0, delta))
	pivot.rotation.x = lerp_angle(pivot.rotation.x, target_pitch, blend)
	pivot.rotation.z = lerp_angle(pivot.rotation.z, target_bank, blend)
