extends Area2D


@export var damage: int = 1


func _on_body_entered(body) -> void:
	body.update_health(damage)


func _on_life_timer_timeout() -> void:
	queue_free()
