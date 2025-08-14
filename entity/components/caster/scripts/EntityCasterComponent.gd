extends Node
class_name EntityCasterComponent

# ---

signal cast_effect(
    effect: PackedScene,
    location: Vector3,
    target_location: Vector3
)

# ---

@export
var entity_root: Node3D

# ---

func cast(effect: PackedScene, target_location: Vector3):
    cast_effect.emit(
        effect,
        entity_root.position,
        target_location
    )
