class_name Network extends LevelBoundController

signal entity_arrived(entity: Node3D, position: Vector3)
signal entity_departed(entity: Node3D, dest_position: Vector3, position: Vector3)

signal netnode_added(entity: Node3D, position: Vector3)
signal netnode_removed(entity: Node3D, position: Vector3)

# ---

@export
var min_point_distance: float = 0

@export
var max_points: int:
	set(value):
		self._astar.reserve_space(max_points)	
	get:
		return self._astar.get_point_capacity()

@export
var connector_scene: PackedScene

# ---

var _astar: AStar3D = AStar3D.new()

# ---

func add_netnode(
	netnode_scene: PackedScene,
	pos: Vector3,
	with_connections: Array[int] = []
) -> Node3D:
	if !self.can_add_point(pos):
		push_warning("Cannot add point!")
		return

	var entity = netnode_scene.instantiate()
	var netnode = self.level.entity_service.get_component_by_type(entity, EntityService.EntityComponentType.NETWORK_NODE)
	if netnode == null:
		push_warning("Cannot add point! Netnode entity must have a NETWORK_NODE component.")
		return

	var point_id = self._astar.get_available_point_id()

	self._astar.add_point(point_id, entity)
	self._attach_connections_to_point(point_id, pos, with_connections)
	self._configure_netnode(netnode, point_id)
	self._attach_netnode_listeners(netnode, pos)

	self.netnode_added.emit(entity, pos)
	return entity

func remove_point(entity: Node3D):
	var point_id = self._find_point_id(entity)
	if point_id == -1:
		push_warning("Is not a point!")
		return

	self._astar.remove_point(point_id)
	self.netnode_removed.emit(entity, entity.position)

func can_add_point(pos: Vector3) -> bool:
	if self._astar.get_point_count() > self.max_points:
		return false

	var closest_point = self._astar.get_closest_point(pos)
	var closest_point_pos = self._astar.get_point_position(closest_point)
	var closest_point_dist = (pos - closest_point_pos).length()
	return closest_point_dist < self.min_point_distance

# ---

func _attach_connections_to_point(point_id: int, point_pos: Vector3, base_connections: Array[int]):
	var connectable: Array[int] = base_connections

	self._astar.set_point_disabled(point_id)

	var p = self._astar.get_closest_point(point_pos)
	var p_dist = (self._astar.get_point_position(p) - point_pos).length()
	
	while (
		p != -1
		and p_dist <= self.max_connection_distance
		and p_dist >= self.min_connection_distance
		and connectable.size() <= self.max_connections
	):
		var to_connect = p

		self._astar.connect_points(point_id, to_connect)

		self._astar.set_point_disabled(to_connect)
		p = self._astar.get_closest_point(point_pos)
		p_dist = (self._astar.get_point_position(p) - point_pos).length()
		self._astar.set_point_disabled(to_connect, false)

	self.astar.set_point_disabled(point_id, false)

func _configure_netnode(netnode: EntityNetworkNodeComponent, point_id: int):
	netnode.network = self
	netnode.network_point_id = point_id
	netnode.connections = self._astar.get_point_connections(point_id)

func _attach_netnode_listeners(netnode: EntityNetworkNodeComponent, pos: Vector3):
	netnode.entity_arrived.connect(self.entity_arrived.emit.bind(pos))
	netnode.entity_departed.connect(self.entity_departed.emit.bind(pos))

func _find_point_id(entity: Node3D) -> int:
	var entity_node_component: EntityNetworkNodeComponent = (
		self.level.entity_service.get_component_by_type(
			entity,
			EntityService.EntityComponentType.NETWORK_NODE
		)
	)

	if entity_node_component == null:
		return -1

	return entity_node_component.point_id
