extends Resource
class_name EffectKernel
## Mutable parameters and bindings for making generic adjustments to Effects.
## This data should be interpreted by the owner Effect to affect its behavior.

# "increases the strength of..."
@export
var strength: float:
    set(value):
        strength = value
        self.emit_changed()

# "increases the size of..."
@export
var size: float:
    set(value):
        size = value
        self.emit_changed()


@export
var duration_secs: float:
    set(value):
        duration_secs = value
        self.emit_changed()


@export
var direction: Vector3:
    set(value):
        direction = value
        self.emit_changed()
