extends Node
class_name TokenService

# ---

signal token_emitted(token: Token)

# ---

@export
var level: Level

@export
var entity_service: EntityService

# ---

func select_token(params: TokenParameters):
    if params.is_exactly:
        self.token_emitted.emit(params.is_exactly)
        return

    var choices = self.level.available_tokens.filter(
        self._parameter_filter(params)
    )

    return choices.pick_random()

# ---

func _ready() -> void:
    await self.level.ready
    self.entity_service.define_component_type_listener(
        EntityService.EntityComponentType.TOKEN,
        &"token_requested",
        self._on_entity_token_requested
    )

func _on_entity_token_requested(
    parameters: TokenParameters,
    _position: Vector3,
    _entity: Node3D,
    _component: EntityTokenComponent
):
    var token = self.select_token(parameters)
    self.token_emitted.emit(token)

func _parameter_filter(params: TokenParameters):
    return func(token: Token):
        return (
            token.cost >= params.cost_range.x
            and token.cost <= params.cost_range.y
            and (
                params.is_type == Token.TokenType.ANY
                or token.type == params.is_type
            )
        )
