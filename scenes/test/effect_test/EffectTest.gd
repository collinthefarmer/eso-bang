extends Node3D
class_name EffectTest

@export
var effect: PackedScene

@export
var entity: PackedScene

@export
var spawn_delay_ms: float = 1000.

@export
var spawn_offset: Vector3 = Vector3.UP * 10.

@export
var spawn_radius: float = 10.

# ---

func _ready() -> void:
    var effect_instance: Effect = effect.instantiate()
    self.add_child(effect_instance)

# ---

var _last_spawn_tick: float

# ---

func _process(delta: float) -> void:
    if Time.get_ticks_msec() > self._last_spawn_tick + self.spawn_delay_ms:
        self._last_spawn_tick = Time.get_ticks_msec()

        var entity = entity.instantiate()
        entity.position += self.spawn_offset + (
            (randf() * 2 - 1) * self.spawn_radius * Vector3(1, 0, 1)
        )
        self.add_child(entity)
