extends Resource
class_name EntityStrategy

@export
var entity_scene: PackedScene

# ---

func next(service: EntityService) -> bool:
    service.create(
        self.spawn_reason,
        self.entity_scene,
        self.select_spawn_position(service.level.geometry)
    )

    return true

func select_spawn_position(level_geometry: LevelGeometry) -> Vector3:
    ## TODO: build out noise layers/fields for choosing a position

    return Vector3(
        level_geometry.kernel.terrain_aabb.size.x * randf(),
        level_geometry.kernel.terrain_aabb.size.y + self.spawn_height_offset,
        level_geometry.kernel.terrain_aabb.size.z * randf()
    )
