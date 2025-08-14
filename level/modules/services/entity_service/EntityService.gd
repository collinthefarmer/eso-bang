class_name EntityService extends Node

# ---

const IS_ENTITY_KEY = &"ENTITY"

# ---

enum EntityComponentType {
    HEAT,
    HITBOX,
    LIFECYCLE,
    TOKEN,
    CASTER,
    CONTROL,
    CAMERA_TARGET,
    NETWORK_TRAVEL,
    NETWORK_NODE
}

# ---

static func is_entity(node: Node3D) -> bool:
    return node.has_meta(IS_ENTITY_KEY)

# ---

signal entity_entered(
    node: Node3D,
    level_position: Vector3,
    reason: Entity.EntityCreatedReason
)

signal entity_exiting(
    node: Node3D,
    level_position: Vector3
)

# ---

@export
var level: Level

@export
var entity_limit: int = 1000

# ---

var entity_pools: Dictionary[PackedScene, ScenePool] = {}

var entity_ct: int = 0

var component_registry = Components.ComponentRegistry.new()

# ---

func define_component(
    scene: PackedScene,
    component_type: EntityComponentType,
    path: NodePath
) -> Components.Component:
    return self.component_registry.define_component(
        scene,
        component_type,
        path
    )

func define_component_listener(
    component: Components.Component,
    signal_name: StringName,
    callable: Callable,
    flags: int = 0
) -> Components.ComponentListener:
    return self.component_registry.define_listener(
        component,
        signal_name,
        callable,
        flags
    )

func define_component_type_listener(
    component_type: EntityComponentType,
    signal_name: StringName,
    callable: Callable,
    flags: int = 0
) -> Array[Components.ComponentListener]:
    return self.component_registry.define_type_listeners(
        component_type,
        signal_name,
        callable,
        flags
    )

func get_component_by_type(
    entity: Node3D,
    component_type: EntityComponentType
) -> Node:
    for comp in self.component_registry.list_by_type(component_type):
        var entity_comp = entity.get_node_or_null(comp.path)
        if entity_comp: return entity_comp

    return null

func get_components(entity: Node3D) -> Node:
    for comp in self.component_registry.list():
        var entity_comp = entity.get_node(comp.path)
        if entity_comp: return entity_comp

    return null

func get_component(entity: Node3D, component: Components.Component) -> Node:
    return entity.get_node_or_null(component.path)

func execute_strategy(strategy: EntityStrategy):
    if await strategy.next(self):
        await get_tree().physics_frame
        await self.execute_strategy(strategy)

func create(
    reason: Entity.EntityCreatedReason,
    entity_scene: PackedScene,
    position: Vector3,
    force: bool = false
) -> Node3D:
    if not (self.entity_ct < self.entity_limit or force): return

    var pool = self._get_pool(entity_scene)
    var instance = pool.checkout_instance()
    if instance == null:
        push_error("Unable to create entity!")
        return

    var entity = instance.instance
    if instance.is_new:
        var on_enter = self._on_entity_entered.bind(entity, position, reason)
        var on_exit = self._on_entity_exiting.bind(entity, pool)
        entity.tree_entered.connect(on_enter)
        entity.tree_exiting.connect(on_exit)
        self._attach_component_listeners(entity)

    self.level.add_child(entity)
    return entity

# ---

func _on_entity_entered(
    entity: Node3D,
    position: Vector3,
    reason: Entity.EntityCreatedReason
):
    self.entity_ct += 1
    self.entity_entered.emit(entity, position, reason)
    entity.position = position

func _on_entity_exiting(entity: Node3D, pool: ScenePool):
    self.entity_ct -= 1
    self.entity_exiting.emit(entity, entity.position)
    pool.return_instance(entity)

func _get_pool(entity_scene: PackedScene) -> ScenePool:
    var pool = self.entity_pools.get(entity_scene)
    if pool == null:
        pool = ScenePool.new(
            entity_scene,
            [IS_ENTITY_KEY],
            0, # todo - need a way of determining these <<< & vvv
            10000
        )
        self.entity_pools.set(entity_scene, pool)
    return pool

func _attach_component_listeners(entity: Node3D):
    for component in self.component_registry.list():
        var entity_comp: Node = self.get_component(entity, component)
        if entity_comp == null: continue
        for listener in self.component_registry.list_listeners(component):
            self._attach_component_listener(entity, entity_comp, listener)

func _attach_component_listener(
    entity: Node3D,
    component_instance: Node,
    listener: Components.ComponentListener
):
    if !component_instance.has_signal(listener.signal_name):
        return

    var component_signal: Signal = component_instance.get(listener.signal_name)
    component_signal.connect(
        listener.callable.bind(entity, component_instance),
        listener.flags
    )
