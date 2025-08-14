extends Node3D
class_name Game

@export
var kernel: GameKernel

@export
var ui_visible_time_scale: float

# ---

@onready
var level: Level = %"Level"

@onready
var token_wall: TokenWall = %TokenWall

# ---

func _ready() -> void:
    self.token_wall.visibility_changed.connect(
        self._on_token_wall_visibility_changed
    )

# ---

func _on_token_wall_visibility_changed():
    if token_wall.visible:
        Engine.time_scale = self.ui_visible_time_scale
    else:
        Engine.time_scale = 1
