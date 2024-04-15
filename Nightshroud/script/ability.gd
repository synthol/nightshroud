extends CanvasLayer

@onready var player = get_parent().get_node('player')
@onready var available = $available
@onready var unavailable = $unavailable

func _ready() -> void:
	if player != null:
		player.connect('ability_changed', Callable(self, '_on_ability_changed'))
		_on_ability_changed(player.is_ability_available())

func _on_ability_changed(is_available):
	available.visible = is_available
	unavailable.visible = !is_available
