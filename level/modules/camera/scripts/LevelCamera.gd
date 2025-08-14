extends Camera3D
class_name LevelCamera

@export
var level: Level

@export
var orbit_distance: float = 1.

@export
var orbit_position: float

@export
var orbit_height: float

# ---

var focus_target: Node3D

# ---

func reposition():
    self.reposition_to_target(
        self.focus_target.position
        if self.focus_target
        else self.level.geometry.kernel.terrain_aabb.get_center()
    )

func reposition_to_target(location: Vector3):
    var level_center = self.level.geometry.kernel.terrain_aabb.get_center()
    var center_offset = location - level_center

    self.position = Vector3(
        level_center.x + (
            sin(self.orbit_position)
            * self.level.geometry.kernel.terrain_aabb.size.x / 2.
            * self.orbit_distance
        ) + center_offset.x,
        self.orbit_height + location.y,
        level_center.z + (
            cos(self.orbit_position)
            * self.level.geometry.kernel.terrain_aabb.size.z / 2.
            * self.orbit_distance
        ) + center_offset.z
    )
    self.look_at(location)

func relative_dir(dir: Vector3):
    var relative = -self.basis.z * dir.z + -self.basis.x * dir.x
    relative.y = 0
    return relative.normalized()

# ---

func _ready() -> void:
    await self.level.ready
    self.level.entity_service.define_component_type_listener(
        EntityService.EntityComponentType.CAMERA_TARGET,
        &"focus_requested",
        self._on_focus_requested
    )

func _process(delta: float) -> void:
    self.reposition()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("camera_rotate_l"):
        self._tween_to_orbit_position(self.orbit_position - PI/4.)

    if event.is_action_pressed("camera_rotate_r"):
        self._tween_to_orbit_position(self.orbit_position + PI/4.)

# ---

var _orbit_position_tween: Tween

# ---

func _on_focus_requested(
    _location: Vector3,
    entity: Node3D,
    _component: EntityCameraTargetComponent
):
    self.focus_target = entity

func _tween_to_orbit_position(pos: float):
    if self._orbit_position_tween and self._orbit_position_tween.is_running():
        return

    self._orbit_position_tween = create_tween()
    self._orbit_position_tween \
        .tween_property(self, "orbit_position", pos, .4) \
        .set_trans(Tween.TRANS_CUBIC)
