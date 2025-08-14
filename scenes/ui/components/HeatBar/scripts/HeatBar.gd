extends ProgressBar
class_name HeatBar

@export
var level: Level

# ---

func _ready() -> void:
    self.max_value = self.level.heat_service.max_heat
    self.level.heat_service.heat_changed.connect(
        self._on_heat_changed
    )

# ---

func _on_heat_changed(change_amt: int, current_amt: int):
    self.value = current_amt
