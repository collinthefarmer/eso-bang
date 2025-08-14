extends Effect
class_name BlackHole

@onready
var area: Area3D = %Area

@onready
var singularity: CollisionShape3D = %Singularity

@onready
var well: CollisionShape3D = %Well

# ---

func _apply_from_kernel():
    self.area.gravity = self.kernel.strength
    self.area.gravity_point_unit_distance = self.kernel.size
    self.well.shape.radius = self.kernel.size

# ---

func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int):
    if self.area.shape_owner_get_owner(
        self.area.shape_find_owner(local_shape_index)
    ) == self.singularity:
        self._on_entered_singularity(body)


func _on_entered_singularity(body: Node3D):
    pass
