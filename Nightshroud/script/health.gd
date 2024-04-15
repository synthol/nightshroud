extends CanvasLayer

var heart = 4
var maxheart = 4
@onready var player = get_parent().get_node('player')
@onready var empty = $empty
@onready var full = $full

func _ready() -> void:
	if player != null:
		player.health_changed.connect(change)

func change(value):
	heart = value
	if heart >= 0:
		if heart <= maxheart:
			full.size.x = heart * 32
