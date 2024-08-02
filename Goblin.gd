extends CharacterBody2D

const ATTACK_AREA: PackedScene = preload("res://goblin/enimy_attack_area.tscn")
const OFFSET: Vector2 = Vector2(0, 31)

var player_ref: CharacterBody2D = null
@onready var animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var receivedDmageAnimation: AnimationPlayer = get_node("HitAnimation")
@onready var texture: Sprite2D = get_node("Sprite2D")
@onready var dust: GPUParticles2D = get_node("Dust")
@onready var attckCollision: CollisionShape2D = get_node("CollisionShape2D")
@onready var areaCollision: CollisionShape2D = get_node("DetectionArea/CollisionShape2D")

@export var move_speed: float = 192.0
@export var distance_threshhold: float = 60.0

@export var health_points: int = 10
@export var damage: int = 2
@export var score_points: int = 100

var can_die: bool = false

func _physics_process(_delta):
	if can_die:
		return 
		
	if player_ref == null or player_ref.can_die:
		velocity = Vector2.ZERO
		animate()
		return
		
	var direction: Vector2 = global_position.direction_to(player_ref.global_position)
	var distance: float = global_position.distance_to(player_ref.global_position)
	
	if distance < distance_threshhold:
		animation.play("attack")
		dust.emitting = false
		return
	
	velocity = direction * move_speed
	move_and_slide()
	animate()
	

func spawn_atack_area() -> void:
	var attack_area = ATTACK_AREA.instantiate()
	attack_area.position = OFFSET
	add_child(attack_area)
	
	
func animate() -> void:
	if velocity.x > 0:
		texture.flip_h = false
		
	if velocity.x < 0:
		texture.flip_h = true
		
	if velocity != Vector2.ZERO:
		animation.play("run")
		dust.emitting = true
		return
		
	dust.emitting = false
	animation.play("idle")

func _on_detection_area_body_entered(body):
	player_ref = body
	animation.play("run")


func _on_detection_area_body_exited(_body):
	player_ref = null


func update_health(value: int) -> void:
	health_points -= value
	
	if health_points <= 0:
		transition_screen.player_score += score_points
		get_tree().call_group("level", "update_score", transition_screen.player_score)
		
		can_die = true
		dust.emitting = false
		animation.play("death")
		attckCollision.set_deferred("disabled", true)
		areaCollision.set_deferred("disabled", true)
		return
		
	receivedDmageAnimation.play("hit")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		get_tree().call_group("level", "increase_kill_count")
		queue_free()
