extends Label
class_name TokenWord

@export
var token: Token: set = _set_token

# ---

func _set_token(value: Token):
    self.text = value.word
