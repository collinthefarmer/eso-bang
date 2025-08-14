extends Resource
class_name StateCache
## Utility class implementing a generic cache that can memoize gets
## Entries can be marked dirty to indicate that they should be recalculated using the
##  resolver Callable provided when the key was set.


enum State {
    CLEAN,
    DIRTY
}

const _RESOLVER_KEY = &"__resolver"
const _VALUE_KEY = &"__value"
const _STATE_KEY = &"__state"

# ---

func cset(key: Variant, resolver: Callable):
    self._dict[key] = {
        _RESOLVER_KEY: resolver,
        _VALUE_KEY: null,
        _STATE_KEY: State.DIRTY
    }
    self.emit_changed()


func cget(key: Variant):
    if self._dict[key][_STATE_KEY] == State.DIRTY:
        self._resolve(key)
    return self._dict[key][_VALUE_KEY]


func set_dirty(key: Variant):
    if not self._dict.has(key): return
    self._dict[key][_STATE_KEY] = State.DIRTY
    self.emit_changed()

# ---

var _dict: Dictionary

# ---

func _init() -> void:
    self._dict = {}


func _resolve(key: Variant):
    self._dict[key][_VALUE_KEY] = self._dict[key][_RESOLVER_KEY].call()
    self._dict[key][_STATE_KEY] = State.CLEAN
