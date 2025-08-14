extends Node3D
class_name LevelGeometry

static func from_kernel(_kernel: LevelGeometryKernel) -> LevelGeometry:
    const SCENE = preload("res://level/modules/geometry/LevelGeometry.tscn")

    var geometry = SCENE.instantiate()
    geometry.kernel = _kernel
    return geometry

# ---

@export
var kernel: LevelGeometryKernel

@export
var level: Level

# ---

@onready
var terrain_trimesh: MeshInstance3D = %TerrainTriMesh

@onready
var terrain_body: StaticBody3D = %TerrainBody

@onready
var terrain_collider: CollisionShape3D = %TerrainCollider

@onready
var terrain_bounds: Area3D = %TerrainBounds

@onready
var terrain_bounds_collider: CollisionShape3D = %BoundsCollider

# ---

func get_height(x: float, y: float):
    return clamp(
        self.kernel.data.sample_height(x, y) * self.kernel.height_scale,
        self.kernel.min_height,
        self.kernel.max_height
    )

# ---

func _ready() -> void:
    self._apply_from_kernel()

    self.kernel.changed.connect(self._apply_from_kernel)
    self.terrain_bounds.body_exited.connect(self._on_terrain_bounds_exited)

# ---

func _apply_from_kernel():
    self.terrain_trimesh.mesh = self.kernel.terrain_trimesh
    self.terrain_collider.shape = self.kernel.terrain_shape
    self.terrain_bounds.position = self.kernel.terrain_aabb.size / 2.
    self.terrain_bounds_collider.shape = self.kernel.terrain_bounds_shape

# ---

func _on_terrain_bounds_exited(body: Node3D):
    if EntityService.is_entity(body):
        (func ():
            if body.get_parent(): self.level.remove_child(body)
        ).call_deferred()
