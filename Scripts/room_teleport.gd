extends Area2D

@export var destination: Area2D

var is_cooling_down : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_cooling_down or destination == null:
		return
	if body.is_in_group("Player"):
		destination.start_cooldown()
		body.global_position = destination.global_position
		get_tree().call_group("Pursuer", "player_used_door", self)
	elif body.is_in_group("Pursuer"):
		destination.start_cooldown()
		body.global_position = destination.global_position
		body.warped()
		
func start_cooldown() -> void:
	is_cooling_down = true
	await get_tree().create_timer(0.4).timeout
	is_cooling_down = false
