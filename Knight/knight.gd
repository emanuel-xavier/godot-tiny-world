extends CharacterBody2D

@onready var animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var receivedDmageAnimation: AnimationPlayer = get_node("ReceivedDmageAnimation")
@onready var sprite: Sprite2D = get_node("sprite2D")
@onready var attackCollision: Area2D = get_node("AttackArea")
@onready var dust: GPUParticles2D = get_node("Dust")

@export var move_speed: float = 256.0
@export var right_atach_x_transform: float = 56.0
@export var left_atach_x_transform: float = -56.0

@export var damage: int = 1
@export var health_points: int = 10

var can_atack: bool = true
var can_die: bool = false

func _ready() -> void:
	if transition_screen.player_health != 0:
		health_points = transition_screen.player_health
		return
		
	transition_screen.player_health = health_points

func _physics_process(_delta) -> void:
	if not can_atack or can_die:
		return
		
	move()
	animate()
	attack_handler()
	
func move() -> void:
	var direction: Vector2 = get_direction()
	velocity = direction * move_speed 
	move_and_slide()
	


func get_direction() -> Vector2:
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()


func animate() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		attackCollision.position.x = right_atach_x_transform
	elif velocity.x < 0:
		sprite.flip_h = true
		attackCollision.position.x = left_atach_x_transform
	
	if not can_atack:
		return
		
	if velocity != Vector2.ZERO:
		animation.play("walk")
		dust.emitting = true
		return
		
	dust.emitting = false
	animation.play("idle")


func attack_handler() -> void:
	if Input.is_action_just_pressed("attack") && can_atack:
		animation.play("attack")
		can_atack = false
		dust.emitting = false
		
 
func on_animation_finished(anim_name: String):
	match anim_name:
		"attack":
			can_atack = true
		"dead":
			transition_screen.player_health = 0
			transition_screen.fade_in()
			attackCollision.set_deferred("disabled", true)


func on_attack_area_body_entered(body):
	body.update_health(damage)
	
func update_health(value: int) -> void:
	health_points -= value
	
	transition_screen.player_health = health_points
	get_tree().call_group("level", "update_health", health_points)
	
	if health_points <= 0:
		can_die = true
		animation.play("dead")
		transition_screen.player_score = 0
		return
		
	receivedDmageAnimation.play("hit")
	
