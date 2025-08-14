extends EntityControlComponent
class_name PlayerControl

@export
var movement_strength: float = 20.

func _physics_process(delta: float) -> void:
    var dir = Vector3(
        Input.get_axis("player_move_right", "player_move_left"),
        0,
        Input.get_axis("player_move_backward", "player_move_forward")
    ).normalized()

    if dir != Vector3.ZERO:
        self.movement_requested.emit(dir, movement_strength * delta)
