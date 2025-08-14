extends Node
class_name HeatService

# ---

signal heat_maxxed
signal heat_changed(amt: int, current_amt: int)

# ---

@export
var max_heat: int = 1000

@export
var level: Level

@export
var entity_service: EntityService

# ---

var heat: float = 0: set = _set_heat

# ---

func get_entity_heat_comp(entity: Node3D) -> EntityHeatComponent:
    if !self.entity_service.is_entity(entity):
        push_error("Non-entity cannot have heat! %" % [entity])
        return

    return self.entity_service.get_component_by_type(
        entity,
        EntityService.EntityComponentType.HEAT
    )

# ---

func _set_heat(value: float):
    self.heat_changed.emit(value - self.heat, self.heat)
    heat = min(value, max_heat)
    if heat == max_heat: self.heat_maxxed.emit()

# ---

func _ready() -> void:
    # todo: change these to be attached in the same way as TokenService (use builtin tree events)
    self.entity_service.entity_entered.connect(self._on_entity_entered)
    self.entity_service.entity_exiting.connect(self._on_entity_exiting)

# ---

func _on_entity_entered(
    node: Node3D,
    position: Vector3,
    reason: Entity.EntityCreatedReason
):
    var heat_component = self.get_entity_heat_comp(node)
    if heat_component == null: return
    heat_component.heat_dispersed.connect(
        self._on_entity_heat_dispersed.bind(node, heat_component)
    )

func _on_entity_exiting(
    node: Node3D,
    position: Vector3
):
    var heat_component = self.get_entity_heat_comp(node)
    if heat_component == null: return
    heat_component.heat_dispersed.disconnect(
        self._on_entity_heat_dispersed.bind(node, heat_component)
    )

func _on_entity_heat_dispersed(
    amt: float,
    position: Vector3,
    entity: Node3D,
    comp: EntityHeatComponent
):
    self.heat += amt
