extends Node3D
class_name EntityHeatComponent

# ---

signal heat_dispersed(amt: float, entity_position: Vector3)
signal heat_exhausted(initial_amt: float, entity_position: Vector3)

# ---

@export
var entity_root: Node3D

@export
var initial_heat_energy: float

# ---

var heat_energy: float

# ---

func disperse(amt: float) -> void:
    var amt_capped = min(amt, self.heat_energy)
    self.heat_energy -= amt_capped
    self.heat_dispersed.emit(amt_capped, self.entity_root.position)

    if self.heat_energy > 0: return
    self.heat_exhausted.emit(self.initial_heat_energy, self.entity_root.position)

func disperse_remaining() -> float:
    var remaining = self.heat_energy
    self.heat_dispersed.emit(remaining, self.entity_root.position)
    self.heat_exhausted.emit(self.initial_heat_energy, self.entity_root.position)
    return remaining

# ---

func _enter_tree() -> void:
    self.heat_energy = self.initial_heat_energy
