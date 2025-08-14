extends EntityHeatComponent

@export
var emission: float

# ---

func _physics_process(delta: float) -> void:
    self.disperse(self.initial_heat_energy * emission * delta)
