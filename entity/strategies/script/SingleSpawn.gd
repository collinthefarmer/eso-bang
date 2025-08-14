extends EntityStrategy
class_name SingleSpawn

@export
var delay: float

@export
var spawn_height_offset: int

# ---

var started_ticks: int = 0

# ---

func next(service: EntityService) -> bool:
    await service.get_tree().create_timer(self.delay, false, true, false).timeout
    service.create(
        Entity.EntityCreatedReason.LEVEL_SPAWN,
        self.entity_scene,
        self.select_spawn_position(service.level.geometry)
    )
    return false

func select_spawn_position(level_geometry: LevelGeometry) -> Vector3:
    ## TODO: build out noise layers/fields for choosing a position

    return Vector3(
        level_geometry.kernel.terrain_aabb.size.x * randf(),
        level_geometry.kernel.terrain_aabb.size.y + self.spawn_height_offset,
        level_geometry.kernel.terrain_aabb.size.z * randf()
    )

# ---
