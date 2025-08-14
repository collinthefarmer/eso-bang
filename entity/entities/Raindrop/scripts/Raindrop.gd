extends RigidBody3D

@onready
var heat: EntityHeatComponent = $"PassiveHeat"

@onready
var lifecycle: EntityLifecycleComponent = $EntityLifecycleComponent

@onready
var token: EntityTokenComponent = $EntityTokenComponent

# ---

func _ready() -> void:
    self.heat.heat_exhausted.connect(self._on_heat_exhausted)
    self.lifecycle.lifecycle_completed.connect(self._on_lifecycle_completed)

func _enter_tree() -> void:
    self.linear_velocity = Vector3.ZERO
    self.angular_velocity = Vector3.ZERO
    self.rotation = Vector3.ZERO

# ---

func _on_heat_exhausted(total_heat: float, location: Vector3):
    if !self.lifecycle.dead:
        self.lifecycle.kill(Entity.EntityKilledReason.HEAT_EXHAUSTED)

func _on_lifecycle_completed(
    lifetime_secs: float,
    lifetime_ticks: int,
    location: Vector3,
    reason: Entity.EntityKilledReason
):
    if reason == Entity.EntityKilledReason.TIMEOUT:
        self.heat.disperse_remaining()

    self.token.request_token()
    self.get_parent().remove_child(self)
