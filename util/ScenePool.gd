class_name ScenePool extends Resource

const POOLED_KEY = &"POOLED"

# ---

static var _last_pool_key: int = 0

# ---

static func generate_pool_key():
    _last_pool_key += 1
    return StringName("POOL_%s" % _last_pool_key)

# ---

@export
var scene: PackedScene

@export
var additional_keys: Array[StringName] = []

@export
var min: int

@export
var max: int

# ---

var ct_active: int
var ct_instantiated: int

# ---

var _pool_key: StringName
var _pool: Array[Node] = []

# ---

func checkout_instance() -> PooledInstance:
    var is_new = false
    var instance = self._pool.pop_back()
    if not instance:
        is_new = true
        instance = self._instantiate()

    if not instance:
        return null

    self.ct_active += 1
    instance.remove_meta(POOLED_KEY)
    return PooledInstance.new(instance, is_new)

func return_instance(instance: Node) -> void:
    if (
        !instance.has_meta(self._pool_key)
        or instance.has_meta(POOLED_KEY)
    ):
        return

    instance.set_meta(POOLED_KEY, true)
    self._pool.push_back(instance)
    self.ct_active -= 1

# ---

func _init(
    _scene: PackedScene,
    _additional_keys: Array[StringName],
    _min: int,
    _max: int
) -> void:
    self.scene = _scene
    self.additional_keys = _additional_keys
    self.min = _min
    self.max = _max

    self._pool_key = ScenePool.generate_pool_key()
    self._pool.resize(self.min)
    for i in range(self.min):
        self._pool[i] = self._instantiate()

# ---

func _instantiate() -> Node:
    if self.ct_instantiated + 1 > self.max:
        push_error("Too many instances!")
        return null

    var instance = self.scene.instantiate()

    instance.set_meta(self._pool_key, true)
    for key in additional_keys:
        instance.set_meta(key, true)

    self.ct_instantiated += 1
    return instance

# ---

class PooledInstance extends RefCounted:
    var instance: Node
    var is_new: bool

    func _init(_instance: Node, _is_new: bool) -> void:
        self.instance = _instance
        self.is_new = _is_new
