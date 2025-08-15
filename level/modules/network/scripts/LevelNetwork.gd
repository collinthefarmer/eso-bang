extends Node3D
class_name LevelNetwork

signal node_added(id: int, pos: Vector3)

# ---

@export
var max_connection_distance: float

@export
var min_connection_distance: float

@export
var max_connections: int

@export
var max_points: int

@export
var level: Level

@export
var entity_service: EntityService

# ---

var nodes: Array[Node3D] = []
var astar: AStar3D = AStar3D.new()
var next_point_id: int = 1

# ---

func add_network_node(scene: PackedScene, pos: Vector3, include_debug: bool = false):
    if self.nodes.size() >= self.max_points:
        push_warning("Cannot add more than max network connections!")
        return

    var node = entity_service.create(
        Entity.EntityCreatedReason.NETWORK_NODE,
        scene,
        Vector3.UP,
        true
    )

    self.astar.add_point(self.next_point_id, pos)

    var connections = 0
    for point in self._select_connectable(self.next_point_id):
        self.astar.connect_points(self.next_point_id, point)
        if include_debug:
            var debug_ray = RayCast3D.new()
            debug_ray.collision_mask = 0
            debug_ray.position = pos + Vector3.UP
            debug_ray.target_position = (self.nodes[point].position - pos)
            self.add_child(debug_ray)

    self.nodes.resize(self.next_point_id + 1)
    self.nodes[self.next_point_id] = node

    node.position = pos

    self.node_added.emit(self.next_point_id, pos)
    self.next_point_id += 1

func get_nearest_node(pos: Vector3) -> Node3D:
    var id = self.astar.get_closest_point(pos)
    if id == -1:
        push_warning("No network nodes!")
        return

    return self.nodes[id]

func get_node_in_direction(
    node: Node3D,
    dir: Vector3,
    ease: float
) -> Node3D:
    var node_id = self.nodes.find(node)
    var node_pos = self.astar.get_point_position(node_id)
    var connected = self.astar.get_point_connections(node_id)

    var best_conn: int = -1
    var best: float = -1
    for conn in connected:
        var conn_pos = self.astar.get_point_position(conn)
        var conn_dir = (conn_pos - node_pos).normalized()
        var dot = conn_dir.dot(dir) ** ease
        if dot > best:
            best = dot
            best_conn = conn

    return self.nodes[best_conn]

# ---

func _ready() -> void:
    await self.level.ready
    self.entity_service.define_component_type_listener(
        EntityService.EntityComponentType.NETWORK_TRAVEL,
        "request_attachment",
        self._on_entity_attachment_requested
    )
    self.entity_service.define_component_type_listener(
        EntityService.EntityComponentType.NETWORK_NODE,
        "tree_entered",
        self._on_node_entered
    )

# ---

func _on_entity_attachment_requested(
    pos: Vector3,
    entity: Node3D,
    component: EntityNetworkTravelComponent
) -> void:
    var attachment_point = self.astar.get_closest_point(pos)
    var attachment_node = self.nodes[attachment_point]
    component.network = self
    component.attached_to = attachment_node
    entity.position = attachment_node.position

func _on_node_entered(node: Node3D, component: EntityNetworkNodeComponent):
    component.network = self
    component.point_id = self.nodes.find(node)
    component.connections = self.astar.get_point_connections(component.point_id)
    print(component)

func _select_connectable(to_id: int):
    var to_pos = self.astar.get_point_position(to_id)
    var connectable: Array[int] = []

    self.astar.set_point_disabled(to_id)
    var closest = self.astar.get_closest_point(to_pos)
    while (
        closest != -1
        and (
            (self.astar.get_point_position(closest) - to_pos).length()
            <= self.max_connection_distance
        )
        and (
            (self.astar.get_point_position(closest) - to_pos).length()
            >= self.min_connection_distance
        )
        and connectable.size() <= self.max_connections
    ):
        self.astar.set_point_disabled(closest)
        connectable.push_back(closest)
        closest = self.astar.get_closest_point(to_pos)

    self.astar.set_point_disabled(to_id, false)
    for point in connectable:
        self.astar.set_point_disabled(point, false)

    return connectable
