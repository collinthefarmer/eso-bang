extends Effect
class_name Push

@onready
var area: Area3D = %Area

@onready
var collider: CollisionShape3D = %Collider

# ---

var push_force: float

# ---

func _apply_from_kernel():
    self.push_force = self.kernel.strength * 1e4
    self.collider.shape.size = Vector3.ONE * self.kernel.size


func _physics_process(delta: float) -> void:
    var push = self.kernel.direction * self.push_force * delta
    for body in self.area.get_overlapping_bodies():
        if body is RigidBody3D:
            body.apply_central_force(push)
