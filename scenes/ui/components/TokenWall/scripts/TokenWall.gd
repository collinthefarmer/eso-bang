extends GridContainer
class_name TokenWall

const WORD = preload("res://scenes/ui/components/TokenWord/TokenWord.tscn")

@export
var level: Level

@export
var max_to_display: int

# ---

func _ready() -> void:
    self.visible = false
    self.level.token_service.token_emitted.connect(
        self._on_token_emitted
    )

func _process(delta: float) -> void:
    if self.get_child_count() > self.max_to_display:
        self.get_child(0).queue_free()

    if Input.is_action_just_pressed("ui_show_token_wall"):
        self.visible = true

    if Input.is_action_just_released("ui_show_token_wall"):
        self.visible = false


# ---

func _on_token_emitted(token: Token) -> void:
    var word = WORD.instantiate()
    word.token = token
    self.add_child(word)
