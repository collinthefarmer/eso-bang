extends Node3D
class_name Player

# ---

@onready
var control: EntityControlComponent = %PlayerControl

@onready
var caster: EntityCasterComponent = %EntityCasterComponent

@onready
var network: EntityNetworkTravelComponent = %EntityNetworkTravelComponent

@onready
var camera_target: EntityCameraTargetComponent = %EntityCameraTargetComponent

# ---

var level: Level:
    get():
        return self.get_parent()

# ---

func move_across_terrain(dir: Vector3, strength: float):
    var movement = dir * strength
    var next_x = self.position.x + movement.x
    var next_z = self.position.z + movement.z
    var next_y = self.level.geometry.get_height(next_x, next_z)
    var next = Vector3(next_x, next_y, next_z)

    if self.level.geometry.kernel.terrain_aabb.has_point(next):
        self.position = next

# ---

func _ready() -> void:
    self.network.request_attach()
    self.camera_target.request_focus()
    self.control.movement_requested.connect(
        self._on_movement_requested
    )

# ---

func _on_movement_requested(dir: Vector3, strength: float):
    var corrected_dir = self.level.camera.relative_dir(dir)
    if self.network.is_attached:
        self.network.move_along_network(corrected_dir, strength)
        return
    self.move_across_terrain(corrected_dir, strength)
