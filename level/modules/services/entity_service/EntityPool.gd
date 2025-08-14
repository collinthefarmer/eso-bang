class_name EntityPool extends Resource

const IS_ENTITY_METADATA_KEY = &"EntityManager__is_entity"
const ENTITY_POOL_METADATA_KEY = &"EntityManager__entity_pool"

# ---

var entity_scene: PackedScene
var pool: Array[Node3D] = []

# ---

func next_entity() -> Node3D:
    var next = pool.pop_back()
    return next if next else self._instantiate_entity()


func push_entity(node: Node3D):
    self.pool.push_back(node)

# ---

func _init(_entity_scene: PackedScene, seed_amount: int = 0) -> void:
    self.entity_scene = _entity_scene
    for i in seed_amount: self.push_entity(self._instantiate_entity())

# ---

func _instantiate_entity() -> Node3D:
    var entity = self.entity_scene.instantiate()
    entity.set_meta(IS_ENTITY_METADATA_KEY, true)
    entity.set_meta(ENTITY_POOL_METADATA_KEY, self)

    return entity
