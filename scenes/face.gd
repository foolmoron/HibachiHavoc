extends Node
class_name Face

@onready var meshContainer: Node3D = $MeshContainer
@onready var meshInstanceClosed: MeshInstance3D = $MeshContainer/MeshClosed
@onready var meshInstanceOpen: MeshInstance3D = $MeshContainer/MeshOpen
@onready var meshInstanceMissing: MeshInstance3D = $MeshContainer/MeshMissing
@onready var meshInstanceZ: float = meshInstanceClosed.position.z

func _process(delta: float) -> void:
	meshInstanceOpen.visible = FaceLandmarker.mouth_open_latest
	meshInstanceClosed.visible = not FaceLandmarker.mouth_open_latest

	if FaceLandmarker.player_detected_latest:
		meshContainer.rotation_degrees = lerp(meshContainer.rotation_degrees, FaceLandmarker.current_rot, 15 * delta)
		meshInstanceOpen.position.z = lerp(meshInstanceOpen.position.z, meshInstanceZ, 10 * delta)
		meshInstanceClosed.position.z = lerp(meshInstanceClosed.position.z, meshInstanceZ, 10 * delta)
		meshInstanceMissing.position.z = lerp(meshInstanceMissing.position.z, meshInstanceZ + 200.0, 10 * delta)
	else:
		meshContainer.rotation_degrees = Vector3(90, 0, 0)
		meshInstanceOpen.position.z = lerp(meshInstanceOpen.position.z, meshInstanceZ + 200.0, 10 * delta)
		meshInstanceClosed.position.z = lerp(meshInstanceClosed.position.z, meshInstanceZ + 200.0, 10 * delta)
		meshInstanceMissing.position.z = lerp(meshInstanceMissing.position.z, meshInstanceZ, 10 * delta)