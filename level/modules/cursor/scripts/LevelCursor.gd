extends Node3D
class_name LevelCursor

enum Mode {
    PLACE_EFFECT = 0
}

# ---

signal cursor_action(ctx: CursorActionContext)

# ---

@export
var level: Level

@export
var mode: Mode

# ---

func _ready() -> void:
    await self.level.ready

    self.level.geometry.terrain_body.input_event.connect(
        self._on_terrain_body_input
    )

# ---

func _on_terrain_body_input(
    camera: Node,
    event: InputEvent,
    event_position: Vector3,
    normal: Vector3,
    shape_idx: int
):
    var ctx = CursorActionContext.new(mode, event, event_position, normal)
    match event.get_class():
        "InputEventMouseMotion":
            self.position = event_position
        "InputEventMouseButton":
            cursor_action.emit(ctx)

# ---

class CursorActionContext:
    var mode: Mode

    var event: InputEvent
    var event_position: Vector3
    var event_normal: Vector3

    func _init(_mode: Mode, _event: InputEvent, _position: Vector3, _normal: Vector3) -> void:
        mode = _mode
        event = _event
        event_position = _position
        event_normal = _normal
