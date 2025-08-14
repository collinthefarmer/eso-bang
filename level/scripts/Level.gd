extends Node3D
class_name Level

const BASIC_PYLON = preload("res://game/network/BasicPylon.tscn")

const AMBIENT_RAINDROP_TINY = preload("res://entity/strategies/AmbientRaindropTiny.tres")
const AMBIENT_RAINDROP_SMALL = preload("res://entity/strategies/AmbientRaindropSmall.tres")
const AMBIENT_RAINDROP = preload("res://entity/strategies/AmbientRaindrop.tres")
const SPAWN_PLAYER = preload("res://entity/strategies/Player.tres")

# ---

@export
var available_tokens: Array[Token] = []

# ---

@onready
var geometry: LevelGeometry = %LevelGeometry

@onready
var camera: LevelCamera = %LevelCamera

@onready
var network: LevelNetwork = %LevelNetwork

@onready
var cursor: LevelCursor = %LevelCursor

@onready
var entity_service: EntityService = %EntityService

@onready
var heat_service: HeatService = %HeatService

@onready
var token_service: TokenService = %TokenService

# ---

func _ready() -> void:
    self.entity_service.define_component(
        load("res://entity/components/heat/PassiveHeat.tscn"),
        EntityService.EntityComponentType.HEAT,
        "PassiveHeat"
    )

    self.entity_service.define_component(
        load("res://entity/components/token/EntityTokenComponent.tscn"),
        EntityService.EntityComponentType.TOKEN,
        "EntityTokenComponent"
    )

    self.entity_service.define_component(
        load("res://entity/components/control/PlayerControl.tscn"),
        EntityService.EntityComponentType.CONTROL,
        "PlayerControl"
    )

    self.entity_service.define_component(
        load("res://entity/components/camera_target/EntityCameraTargetComponent.tscn"),
        EntityService.EntityComponentType.CAMERA_TARGET,
        "EntityCameraTargetComponent"
    )

    self.entity_service.define_component(
        load("res://entity/components/network_travel/EntityNetworkTravelComponent.tscn"),
        EntityService.EntityComponentType.NETWORK_TRAVEL,
        "EntityNetworkTravelComponent"
    )

    self.entity_service.define_component(
        load("res://entity/components/network_node/EntityNetworkNodeComponent.tscn"),
        EntityService.EntityComponentType.NETWORK_NODE,
        "EntityNetworkNodeComponent"
    )

    self.entity_service.execute_strategy(AMBIENT_RAINDROP)
    self.entity_service.execute_strategy(AMBIENT_RAINDROP_SMALL)
    self.entity_service.execute_strategy(AMBIENT_RAINDROP_TINY)

    self.cursor.cursor_action.connect(
        func (ctx: LevelCursor.CursorActionContext):
            if ctx.event.pressed:
                self.network.add_network_node(BASIC_PYLON, ctx.event_position)
    )

    self.network.node_added.connect(
        self._on_first_network_node,
        CONNECT_ONE_SHOT
    )

func _on_first_network_node(
    id: int,
    pos: Vector3
):
    self.entity_service.execute_strategy(SPAWN_PLAYER)
