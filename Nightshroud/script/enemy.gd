extends CharacterBody2D

var speed = 75
var health = 100
var dead = false
var area = false
var player
var last = Vector2.ZERO
var attack_area = false
var attack_cooldown = 1.0
var last_attack = 0.0
@onready var attacksfx: AudioStreamPlayer = $attacksfx

func _ready() -> void:
	dead = false

func _physics_process(delta: float) -> void:
	if dead:
		return
	last_attack += delta
	if area and player:
		follow()
	elif not area:
		velocity = Vector2.ZERO
		if $AnimatedSprite2D.animation != determine():
			$AnimatedSprite2D.play(determine())
	move_and_slide()

func follow():
	if dead:
		return
	var direction = (player.position - position).normalized()
	last = direction
	velocity = direction * speed
	if not dead:
		anim(player.position - position)
	if attack_area and last_attack >= attack_cooldown:
		attack()

func anim(diff: Vector2) -> void:
	if dead:
		return
	var animate = 'front idle'
	if abs(diff.x) > abs(diff.y):
		animate = 'left walk' if diff.x < 0 else 'right walk'
	else:
		animate = 'back walk' if diff.y < -10 else 'front walk'
	if $AnimatedSprite2D.animation != animate:
		$AnimatedSprite2D.play(animate)

func attack() -> void:
	if dead:
		return
	player.damage(25)
	last_attack = 0.0

func determine() -> String:
	if abs(last.x) > abs(last.y):
		return 'left idle' if last.x < 0 else 'right idle'
	else:
		return 'back idle' if last.y < -0.1 else 'front idle'
		
func _on_attacked_body_entered(body: Node2D) -> void:
	if body.is_in_group('player') and body.invulnerable:
		health -= 50
		attacksfx.play()
		if health <= 0 and not dead:
			dead = true
			$AnimatedSprite2D.play('death')
			$death.start()
		
func _on_attacking_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		attack_area = true

func _on_attacking_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		attack_area = false

func _on_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		area = true
		player = body

func _on_detect_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		area = false
		player = null
		
func _on_death_timeout() -> void:
	queue_free()
