extends Node3D
class_name EntityTokenComponent

# ---

signal token_requested(
    parameters: TokenParameters,
    location: Vector3
)

# ---

@export
var entity_root: Node3D

@export
var token_parameters: TokenParameters

# ---

func request_token():
    self.token_requested.emit(
        self.token_parameters,
        self.entity_root.position
    )
