extends Node
class_name EntityNetworkTravelComponent

signal request_attachment(pos: Vector3)

signal attached(network: LevelNetwork, to: Node3D)

# ---

@export
var entity_root: Node3D

@export
var direction_ease: float = 1.

@export
var snap: float = 1.

@export
var speed: float = 1.

# ---

var network: LevelNetwork

var attached_to: Node3D:
    set(value):
        attached_to = value
        self.attached.emit(self.network, attached_to)

var is_attached: bool:
    get:
        return self.attached_to != null

var dest: Variant = null # Vector3 or null

# ---

func request_attach():
    self.request_attachment.emit(self.entity_root.position)

func move_along_network(dir: Vector3, strength: float):
    if self.dest == null:
        var dest_node = self.network.get_node_in_direction(
            self.attached_to,
            dir,
            self.direction_ease
        )

        if dest_node == null:
            return null

        self.dest = dest_node.position

    var movement = self._calculate_network_move(dir, strength)
    if movement == Vector3.ZERO:
        self.dest = null
        self.request_attach()
        return

    self.entity_root.position += movement

# ---

func _calculate_network_move(dir: Vector3, strength: float) -> Variant:
    var orig = self.attached_to.position
    var axis = (self.dest - self.entity_root.position).normalized() # axis along which movement will occur
    var sign = sign(axis.dot(dir)) # 1d direction of travel (positive or negative)

    var potential_movement = axis * sign * strength * self.speed
    var next_t = (self.entity_root.position + potential_movement) / axis
    var dest_t = self.dest / axis
    var orig_t = orig / axis

    if (next_t > dest_t) or (next_t < orig_t):
        return Vector3.ZERO

    return potential_movement
