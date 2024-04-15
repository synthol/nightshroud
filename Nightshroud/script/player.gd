extends CharacterBody2D

const SPEED := 100
var state: String = 'idle'
var direction := Vector2(0, 1)
var health := 100
var increased = SPEED * 1.5
var invulnerable = false
var ability = false
var available = true
@onready var abilitysfx: AudioStreamPlayer = $abilitysfx
@onready var attackedsfx: AudioStreamPlayer = $attackedsfx
signal health_changed(value)
signal ability_changed(available)

func _ready() -> void:
	$AnimatedSprite2D.play('front idle')

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector('left', 'right', 'forward', 'backward')
	var current = SPEED
	if invulnerable:
		current = increased
	if dir.length() != 0:
		state = 'walk'
		direction = dir
	else:
		state = 'idle'
	velocity = dir * current
	move_and_slide()
	if not ability:
		animation(direction)
	if Input.is_action_just_pressed('ability') and $ability.is_stopped():
		activate()
	
func animation(dir: Vector2) -> void:
	if state == 'idle':
		if dir.y == -1:
			$AnimatedSprite2D.play('back idle')
		elif dir.x == 1:
			$AnimatedSprite2D.play('right idle')
		elif dir.y == 1:
			$AnimatedSprite2D.play('front idle')
		elif dir.x == -1:
			$AnimatedSprite2D.play('left idle')
	elif state == 'walk':
		if dir.y == -1:
			$AnimatedSprite2D.play('back walk')
		elif dir.x == 1:
			$AnimatedSprite2D.play('right walk')
		elif dir.y == 1:
			$AnimatedSprite2D.play('front walk')
		elif dir.x == -1:
			$AnimatedSprite2D.play('left walk')
			
func damage(amount: int) -> void:
	if not invulnerable:
		health -= amount
		attackedsfx.play()
		emit_signal('health_changed', health / 25)
		if health <= 0:
			get_tree().change_scene_to_file('res://scene/restart.tscn')
			
func activate() -> void:
	invulnerable = true
	ability = true
	available = false
	emit_signal('ability_changed', available)
	$invulnerability.start()
	$ability.start()
	$AnimatedSprite2D.play('ability')
	abilitysfx.play()
	
func is_ability_available() -> bool:
	return available
	
func _on_ability_timeout() -> void:
	available = true
	emit_signal('ability_changed', available)

func _on_invulnerability_timeout():
	invulnerable = false
	ability = false

func _on_end_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		get_tree().change_scene_to_file("res://scene/restart.tscn")
