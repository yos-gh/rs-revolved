class_name MultiMeshStream
extends RefCounted

## Streams per-frame instance transforms into a TRANSFORM_3D MultiMesh with a single buffer upload.
## Capacity only grows and the drawn count is set through visible_instance_count, so a changing
## instance count does not reallocate the MultiMesh storage every frame.

const FLOATS_PER_INSTANCE := 12
const MIN_CAPACITY := 16

var instance: MultiMeshInstance3D
var multimesh: MultiMesh
var buffer := PackedFloat32Array()
var count := 0


func _init(target: MultiMeshInstance3D) -> void:
	instance = target
	multimesh = target.multimesh
	multimesh.instance_count = 0
	multimesh.visible_instance_count = 0


func begin() -> void:
	count = 0


func add(transform: Transform3D) -> void:
	if count >= multimesh.instance_count:
		_grow()
	var o := count * FLOATS_PER_INSTANCE
	var basis := transform.basis
	var origin := transform.origin
	buffer[o] = basis.x.x
	buffer[o + 1] = basis.y.x
	buffer[o + 2] = basis.z.x
	buffer[o + 3] = origin.x
	buffer[o + 4] = basis.x.y
	buffer[o + 5] = basis.y.y
	buffer[o + 6] = basis.z.y
	buffer[o + 7] = origin.y
	buffer[o + 8] = basis.x.z
	buffer[o + 9] = basis.y.z
	buffer[o + 10] = basis.z.z
	buffer[o + 11] = origin.z
	count += 1


func commit() -> void:
	multimesh.visible_instance_count = count
	# An empty batch would still cost a draw call, so hide the node instead.
	instance.visible = count > 0
	if count > 0:
		multimesh.buffer = buffer


func clear() -> void:
	begin()
	commit()


func _grow() -> void:
	var capacity := maxi(MIN_CAPACITY, multimesh.instance_count * 2)
	buffer.resize(capacity * FLOATS_PER_INSTANCE)
	multimesh.instance_count = capacity
