extends Node3D
class_name Effect

@export
var kernel: EffectKernel

# ---

func _ready() -> void:
    self._apply_from_kernel()
    self.kernel.changed.connect(self._apply_from_kernel)

    self._start()


func _start():
    self._effect_setup()
    if self.kernel.duration_secs == -1:
        pass

    await get_tree().create_timer(self.kernel.duration_secs).timeout
    self._effect_teardown()


## To be overridden by implementations of Effect.
func _apply_from_kernel():
    pass


## To be overridden by implementations of Effect.
func _effect_setup():
    pass


## To be overridden by implementations of Effect.
func _effect_teardown():
    pass
