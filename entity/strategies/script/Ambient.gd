extends EntityStrategy

@export_range(0, 100)
var rate: float

@export
var spawn_height_offset: int

# ---

var rate_remainder: float
var last_active_ticks: int

# ---

func next(service: EntityService) -> bool:
    var now_ticks = Time.get_ticks_msec()
    var ticks_elapsed = (now_ticks - self.last_active_ticks) * Engine.time_scale
    var accumulated_spawn = (ticks_elapsed * rate / 1000.0) + self.rate_remainder

    for i in range(int(accumulated_spawn)):
        service.create(
            Entity.EntityCreatedReason.LEVEL_SPAWN,
            self.entity_scene,
            self.select_spawn_position(service.level.geometry)
        )

    self.rate_remainder = fmod(accumulated_spawn, 1)
    self.last_active_ticks = now_ticks
    return true

func select_spawn_position(level_geometry: LevelGeometry) -> Vector3:
    ## TODO: build out noise layers/fields for choosing a position

    return Vector3(
        level_geometry.kernel.terrain_aabb.size.x * randf(),
        level_geometry.kernel.terrain_aabb.size.y + self.spawn_height_offset,
        level_geometry.kernel.terrain_aabb.size.z * randf()
    )
