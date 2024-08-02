extends Node2D

@onready var interface: CanvasLayer = get_node("Interface")
@onready var health_label: Label = interface.get_node("HealthLabel")
@onready var score_label: Label = interface.get_node("Score")

var kill_count: int = 0

@export var target_kill_count: int
@export var next_level_scene_path: String
@export var current_level_scene_path: String

func _ready() -> void:
	update_health(transition_screen.player_health)
	update_score(transition_screen.player_score)
	transition_screen.scene_path = current_level_scene_path
	
func update_health(new_health: int) -> void:
	health_label.text = "Hp: " + str(new_health)
	
func update_score(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)

func increase_kill_count() -> void:
	kill_count += 1
	
	if kill_count >= target_kill_count:
		transition_screen.scene_path = next_level_scene_path
		transition_screen.fade_in(true)
