extends Resource
class_name Token

enum TokenType {
    ANY = -1
}

# ---

@export
var cost: int

@export
var name: StringName

@export
var word: String

@export
var type: TokenType
