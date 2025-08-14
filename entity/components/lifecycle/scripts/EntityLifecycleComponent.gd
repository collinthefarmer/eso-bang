extends Timer
class_name EntityLifecycleComponent

# ---

signal lifecycle_completed(
    lived_time: float,
    lived_ticks: int,
    entity_position: Vector3,
    reason: Entity.EntityKilledReason
)

# ---

@export
var entity_root: Node3D

# ---

var born_ticks: int

var dead: bool = false

# ---

func kill(reason: Entity.EntityKilledReason) -> void:
    self.dead = true
    self.lifecycle_completed.emit(
        self.wait_time - self.time_left,
        Time.get_ticks_msec() - self.born_ticks,
        self.entity_root.position,
        reason
    )
    self.stop()

# ---

func _init() -> void:
    self.timeout.connect(self._on_timeout)

func _enter_tree() -> void:
    self.dead = false
    self.born_ticks = Time.get_ticks_msec()
    self.start(self.wait_time)

func _exit_tree() -> void:
    self.stop()

# ---

func _on_timeout():
    self.dead = true
    self.lifecycle_completed.emit(
        self.wait_time,
        Time.get_ticks_msec() - self.born_ticks,
        self.entity_root.position,
        Entity.EntityKilledReason.TIMEOUT
    )
