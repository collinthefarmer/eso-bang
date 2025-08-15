class_name NetworkService extends LevelBoundService

signal network_added(network: Network)
signal network_removed(network: Network)

signal point_added(entity: Node3D, point_id: int, network: Network)
signal point_removed(entity: Node3D, point_id: int, network: Network)

# ---

@export
var max_networks: int

# ---

var networks: Array[Network] = []

# ---

func add_network():
	if !(self.networks.size() < self.max_networks):
		push_warning("Too many networks!")
		return

	var network = Network.new()
	self._connect_listeners(network)

	self.networks.push_back(network)
	self.network_added.emit(network)
	return network

func remove_network(network: Network):
	self.networks = self.networks.filter(func(n: Network): return n != network)
	self.network_removed.emit(network)

# ---

func _connect_listeners(network: Network):
	network.node_added.connect(self.point_added.emit.bind(network))
	network.netnode_removed.connect(self.point_removed.emit.bind(network))

# ---

