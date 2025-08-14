extends Node3D
class_name EntityCameraTargetComponent

signal focus_requested(location: Vector3)

# ---

@export
var entity_root: Node3D

# ---

func request_focus():
    self.focus_requested.emit(self.entity_root.position)
