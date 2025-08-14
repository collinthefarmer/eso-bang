extends Node
class_name EffectService

enum EffectCreatedReason {
    ENTITY_CAST
}

# ---

@export
var entity_service: EntityService

# ---

func get_entity_caster_comp(entity: Node3D) -> EntityCasterComponent:
    if !self.entity_service.is_entity(entity):
        push_error("Non-entity cannot have caster! %" % [entity])
        return

    return self.entity_service.get_component_by_type(
        entity,
        EntityService.EntityComponentType.CASTER
    )

func create_effect(
    reason: EffectCreatedReason,
    effect_scene: PackedScene,
    position: Vector3,
    force: bool = false
):
    pass

func can_cast(
    entity: Node3D,
    effect: PackedScene,
    entity_position: Vector3,
    target_position: Vector3
):
    pass

# ---

func _ready() -> void:
    self.entity_service.entity_entered.connect(self._on_entity_entered)
    self.entity_service.entity_exiting.connect(self._on_entity_exiting)

# ---

func _on_entity_entered(
    node: Node3D,
    level_position: Vector3,
    reason: Entity.EntityCreatedReason
):
    var caster = self.get_entity_caster_comp(node)
    if caster == null: return
    caster.cast_effect.connect(self._on_entity_cast_effect.bind(node))

func _on_entity_exiting(
    node: Node3D,
    level_position: Vector3
):
    var caster = self.get_entity_caster_comp(node)
    if caster == null: return
    caster.cast_effect.disconnect(self._on_entity_cast_effect.bind(node))

func _on_entity_cast_effect(
    effect: PackedScene,
    entity_position: Vector3,
    target_position: Vector3,
    entity: Node3D
):
    if (self.can_cast(entity, effect, entity_position, target_position)):
        self.create_effect(
            EffectCreatedReason.ENTITY_CAST,
            effect,
            target_position
        )
